package net.bbmsoft.fxtended.annotations.binding.impl

import java.util.Locale
import javafx.application.Platform
import net.bbmsoft.fxtended.annotations.binding.BindableProperty
import net.bbmsoft.fxtended.annotations.binding.CheckFXThread
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableTypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility

/**
 *
 * AccessorsHelper
 *
 * @author Michael Bachmann
 *
 */
class AccessorsHelper {

	final extension TransformationContext context
	final extension TypeHelper typeHelper

	new(TransformationContext context) {
		this.context = context
		this.typeHelper = new TypeHelper(context)
	}

	def boolean hasGetter(MutableTypeDeclaration clazz, MutableFieldDeclaration field) {

		val getterName = '''«IF PropertyType.BOOLEAN.equals(field.type.findType)»is«ELSE»get«ENDIF»«field.simpleName.toFirstUpper»'''

		clazz.declaredMethods.filter[simpleName == getterName && parameters.size == 0].size > 0
	}

	def boolean hasSetter(MutableTypeDeclaration clazz, MutableFieldDeclaration field) {

		val setterName = '''set«field.simpleName.toFirstUpper»'''

		clazz.declaredMethods.filter[simpleName == setterName && parameters.size == 1 && field.type.isAssignableFrom(parameters.get(0).type)].size > 0
	}

	def addLazyDelegate(MutableTypeDeclaration clazz, String lazyDelegateName, TypeReference fieldType, MutableFieldDeclaration field) {

		clazz.addField(lazyDelegateName)[
			type = fieldType
			visibility = Visibility.PRIVATE
			val initializerStrg = '''«field.initializer ?: fieldType.defaultValue»'''
			initializer = [initializerStrg]
		]
	}

	def String getDefaultValue(TypeReference reference) {
		if(reference == primitiveBoolean) {
			'false'
		} else if(reference == primitiveByte) {
			'0x00'
		} else if(reference == primitiveChar) {
			'(char) 0'
		} else if(reference == primitiveDouble) {
			'0.0'
		} else if(reference == primitiveFloat) {
			'0.0f'
		} else if(reference == primitiveInt) {
			'0'
		} else if(reference == primitiveLong) {
			'0L'
		} else if(reference == primitiveShort) {
			'0'
		} else {
			'null'
		}
	}

	def addProperty(MutableTypeDeclaration clazz, String fieldName, String propertyName, boolean readOnly,
		boolean styleable, String pseudoClassName, TypeReference implType, TypeReference publicType, boolean lazy,
		String initialValue, boolean isStatic, String doc, MutableFieldDeclaration field,
		String invalidatedMethodName, boolean invalidatedArg, boolean checkFX) {

		clazz.addField(propertyName) [

			type = if(readOnly) implType else publicType
			if(!lazy) final = true
			static = isStatic
			visibility = Visibility.PRIVATE

			if (!lazy) {

				val newStatement = '''new «implType.name.replace('$', '.')»('''
				val cssMetaData = if(styleable) '''«fieldName.toUpperCase(Locale.US)», ''' else ''
				val bean = 'this, '
				val name = '''"«fieldName»"«IF !initialValue.empty», «ENDIF»'''
				val init = '''«initialValue»)'''

				val checkFXbody = if(!checkFX) '' else {

					val annotation = field.findAnnotation(CheckFXThread.newTypeReference.type)
					val exceptionType = annotation.getValue('exception') as TypeReference
					val exceptionMessage = annotation.getValue('message').toString
					val type = field.declaringType
					'''
						if(«type.simpleName».this.getScene() != null && !«Platform.name».isFxApplicationThread()) {
							throw new «exceptionType»("«exceptionMessage» Current thread = " + Thread.currentThread().getName());
						}
					'''
				}

				val invalidated = if(pseudoClassName !== null) '''
					{
						@Override protected void invalidated() {
							«checkFXbody»
							pseudoClassStateChanged(«pseudoClassName», get());
						}
					}
				''' else if(invalidatedMethodName !== null) '''
					{
						@Override protected void invalidated() {
							«checkFXbody»
							«invalidatedMethodName»(«IF invalidatedArg»get()«ENDIF»);
						}
					}
				''' else if(checkFX) '''
					{
						@Override protected void invalidated() {
							«checkFXbody»
						}
					}
				''' else ''

				initializer = ['''«newStatement»«cssMetaData»«bean»«name»«init»«invalidated»''']
			}

			docComment = doc

			field.annotations.filter[annotationTypeDeclaration.isAssignableFrom(BindableProperty.newTypeReference.type)].forEach[a | addAnnotation(a)]
		]
	}

	def addGetter(MutableTypeDeclaration clazz, MutableFieldDeclaration field, String fieldName, TypeReference fieldType,
		boolean lazy, String propertyName, String lazyDelegateName, boolean isStatic, String doc, boolean synchronize) {

		clazz.addMethod('''«IF PropertyType.BOOLEAN.equals(field.type.findType)»is«ELSE»get«ENDIF»«fieldName.toFirstUpper»''') [

			returnType = fieldType
			final = true
			static = isStatic
			synchronized = synchronize
			val bodyStrg = if(lazy) {
				'''
				if(«propertyName» == null) {
				  return «lazyDelegateName»;
				} else {
				  return this.«propertyName».get();
				}
			  	'''
			} else {
				'''return «propertyName».get();'''
			}
			body = [bodyStrg]
//			docComment = doc
		]
	}

	def addSetter(MutableTypeDeclaration clazz, String fieldName, boolean readOnly, boolean lazy, String propertyName,
		String lazyDelegateName, TypeReference fieldType, boolean isStatic, String doc, boolean synchronize) {

		clazz.addMethod('''set«fieldName.toFirstUpper»''') [

			if(readOnly)
				visibility = Visibility.PRIVATE
			final = true
			static = isStatic
			synchronized = synchronize
			val bodyStrg = if(lazy) {
			'''
				if(«propertyName» == null) {
				  «lazyDelegateName» = value;
				} else {
				  this.«propertyName».set(value);
				}
			'''
			} else {
				'''«propertyName».set(value);'''
			}
			body = [bodyStrg]
			addParameter('value', fieldType)

//			docComment = doc
		]
	}

	def addPropertyAccessor(MutableTypeDeclaration clazz, String fieldName, TypeReference publicType, boolean lazy, String propertyName, TypeReference implType, String lazyDelegateName, boolean readOnly, boolean isStatic) {

		val propertyRef = if(readOnly) '''«propertyName».getReadOnlyProperty()''' else propertyName

		clazz.addMethod('''«fieldName»Property''') [

			returnType = publicType
			final = true
			static = isStatic
			val bodyStrg = if(lazy) {
				'''
				if(«propertyName» == null) {
				  «propertyName» = new «implType.name.replace('$', '.')»(«lazyDelegateName»);
				}
				return «propertyRef»;
			  	'''
			} else {
				'''return «propertyRef»;'''
			}
			body = [bodyStrg]
		]
	}
}