package net.bbmsoft.fxtended.annotations.binding.impl

import java.lang.annotation.Annotation
import java.util.List
import java.util.Locale
import java.util.Map
import javafx.scene.Node
import net.bbmsoft.fxtended.annotations.binding.BindableProperty
import net.bbmsoft.fxtended.annotations.binding.CheckFXThread
import net.bbmsoft.fxtended.annotations.binding.Invalidated
import net.bbmsoft.fxtended.annotations.binding.Lazy
import net.bbmsoft.fxtended.annotations.binding.PseudoClass
import net.bbmsoft.fxtended.annotations.binding.ReadOnly
import net.bbmsoft.fxtended.annotations.binding.Styleable
import org.eclipse.xtend.lib.macro.AbstractFieldProcessor
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableTypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.Type
import org.eclipse.xtend.lib.macro.declaration.TypeReference

/**
 * @author Michael Bachmann
 *
 */
class BindablePropertyProcessor extends AbstractFieldProcessor {

	extension TypeHelper typeHelper
	extension AccessorsHelper accessorsHelper
	extension BindablePropertyCssMetadataHelper cssHelper
	extension PseudoClassHelper pseudoClassHelper

	final Map<Type, List<StyleableFieldInfo>> styleInfos

	new() {
		this.styleInfos = newHashMap
	}

	override doTransform(MutableFieldDeclaration annotatedField, extension TransformationContext context) {

		this.typeHelper = new TypeHelper(context)
		this.accessorsHelper = new AccessorsHelper(context)
		this.cssHelper = new BindablePropertyCssMetadataHelper(context)
		this.pseudoClassHelper = new PseudoClassHelper(context)

		val type = annotatedField.declaringType

		context.transformIntoBindableProperty(annotatedField)

		if (type instanceof MutableClassDeclaration) {
			val styleInfo = styleInfos.get(type)
			if(styleInfo !== null) type.addCssMetadata(styleInfo)
		}
	}

	private def void transformIntoBindableProperty(extension TransformationContext context,
		MutableFieldDeclaration field) {

		val clazz = field.declaringType

		val fieldName = field.simpleName
		val fieldType = field.type
		val fieldDoc = field.docComment

		val bindableClass = BindableProperty
		val styleableClass = Styleable
		val readOnlyClass = ReadOnly
		val lazyClass = Lazy
		val invalidatedClass = Invalidated
		val pseudoClassClass = PseudoClass
		val checkFXClass = CheckFXThread

		val styleable = context.hasAnnotation(field, styleableClass)
		val readOnly = context.hasAnnotation(field, readOnlyClass)
		val lazy = context.hasAnnotation(field, lazyClass)
		val invalidated = context.hasAnnotation(field, invalidatedClass)
		val pseudoClass = context.hasAnnotation(field, pseudoClassClass)
		val checkFX = context.hasAnnotation(field, checkFXClass)
		val doCheckFX = checkFX && Node.newTypeReference.type.isAssignableFrom(field.declaringType)

		val bindableAnnotation = field.findAnnotation(findTypeGlobally(bindableClass))
		val synchronize = bindableAnnotation.getBooleanValue('synchronize')

		val invalidatedMethodName = field.findAnnotation(invalidatedClass.newTypeReference.type)?.getValue('value')?.
			toString

		val oneArgMethod = if(invalidatedMethodName !== null) clazz.findDeclaredMethod(invalidatedMethodName, fieldType)
		val noArgMethod = if(invalidatedMethodName !== null) clazz.findDeclaredMethod(invalidatedMethodName)

		val argsCount = if(oneArgMethod !== null) 1 else if(noArgMethod !== null) 0 else -1

		oneArgMethod?.markAsRead
		noArgMethod?.markAsRead

		if (checkFX && !doCheckFX) {
			field.
				addWarning('''Annotation «CheckFXThread.simpleName» has no effect on classes that are not derived from «Node.name»''')
		}

		if (invalidated && argsCount == -1) {
			field.
				addError('''No method called «invalidatedMethodName» that takes either one argument of type «field.type» or no argument exists in this class.''')
			return
		}

		if (invalidated && pseudoClass) {
			field.addError("Field can only have either @Invalidated or @Pseudoclass annotation, but not both.")
			return
		}

		if (pseudoClass && !fieldType.isBoolean(context)) {
			field.addError("Type mismatch: only boolean properties can trigger a pseudo class state change.")
			return
		}

		if (lazy && styleable) {
			field.addError("Lazy styleable properties aren't supported yet.")
			return
		}

		if (readOnly && styleable) {
			field.addError("A read-only property cannot be styleable.")
			return
		}

		val publicType = field.type.findPublicType(readOnly, styleable)
		val implType = field.type.findImplType(readOnly, styleable)

		val propertyName = '''_«fieldName»Property'''

		val lazyDelegateName = '''_«fieldName»'''
		val initialValue = field.initializer?.toString ?: ""

		val static = field.isStatic

		val pseudoClassAnnotationValue = field.findAnnotation(pseudoClassClass.newTypeReference.type)?.
			getValue('value')?.toString
		val pseudoClassName = if(pseudoClassAnnotationValue !== null) pseudoClassAnnotationValue.transformPseudoClassName

		if (pseudoClass) {
			field.declaringType.addPseudoClass(field, pseudoClassAnnotationValue)
		}

		if (lazy) {
			addLazyDelegate(clazz, lazyDelegateName, fieldType, field)
		}

		addProperty(clazz, fieldName, propertyName, readOnly, styleable, pseudoClassName, implType, publicType, lazy,
			initialValue, static, fieldDoc, field, invalidatedMethodName, argsCount != 0, doCheckFX)

		if (!hasGetter(clazz, field)) {
			addGetter(clazz, field, fieldName, fieldType, lazy, propertyName, lazyDelegateName, static, fieldDoc, synchronize)
		}

		if (!hasSetter(clazz, field)) {
			addSetter(clazz, fieldName, readOnly, lazy, propertyName, lazyDelegateName, fieldType, static, fieldDoc, synchronize)
		}

		addPropertyAccessor(clazz, fieldName, publicType, lazy, propertyName, implType, lazyDelegateName, readOnly,
			static)

		if (styleable) {
			context.makeStyleable(clazz, field, styleableClass, fieldName, propertyName, fieldType)
		}

		field.remove
	}

	private def boolean isBoolean(TypeReference type, extension TransformationContext context) {

		type == primitiveBoolean || Boolean.newTypeReference.isAssignableFrom(type)
	}

	private def makeStyleable(extension TransformationContext context, MutableTypeDeclaration clazz,
		MutableFieldDeclaration field, Class<Styleable> styleableClass, String fieldName, String propertyName,
		TypeReference fieldType) {

		if (clazz instanceof MutableClassDeclaration) {
			context.makeStyleable(clazz, field, styleableClass, fieldName, propertyName, fieldType)
		}
	}

	private def makeStyleable(extension TransformationContext context, MutableClassDeclaration clazz,
		MutableFieldDeclaration field, Class<Styleable> styleableClass, String fieldName, String propertyName,
		TypeReference fieldType) {

		if (!javafx.css.Styleable.newTypeReference.type.isAssignableFrom(clazz)) {
			field.addError("Class must implement javafx.css.Styleable in order to have styleable properties")
			return
		}

		if (field.initializer === null) {
			field.addError('''Styleable properties must have an initial value''')
			return
		}

		context.doMakeStyleable(field, styleableClass, fieldName, clazz, propertyName, fieldType)
	}

	private def doMakeStyleable(extension TransformationContext context, MutableFieldDeclaration field,
		Class<Styleable> styleableClass, String fieldName, MutableClassDeclaration clazz, String propertyName,
		TypeReference fieldType) {

		val styleableAnnotation = field.findAnnotation(styleableClass.newTypeReference?.type)

		val accessor = '''«fieldName»Property()'''
		val metadataName = fieldName.toUpperCase(Locale.US)
		val selector = styleableAnnotation.getStringValue("value")
		val supertype = clazz.extendedClass
		val styleInfo = field.collectStyleInfo(propertyName, accessor, metadataName, selector, field.initializer,
			clazz.newTypeReference, fieldType, supertype, fieldType)

		if (styleInfo === null) {
			field.addError('''Style conversion for type «fieldType.name» not yet implemented.''')
		} else {

			val type = field.declaringType
			val infos = styleInfos.get(type) ?: newArrayList => [styleInfos.put(type, it)]
			infos.add(styleInfo)
		}
	}

	private def boolean hasAnnotation(extension TransformationContext context, MutableFieldDeclaration field,
		Class<? extends Annotation> annotationClass) {

		val annotationType = annotationClass.newTypeReference?.type

		if (annotationType === null) {
			return false
		}

		val theAnnotation = field.findAnnotation(annotationType)

		return theAnnotation !== null
	}

}
