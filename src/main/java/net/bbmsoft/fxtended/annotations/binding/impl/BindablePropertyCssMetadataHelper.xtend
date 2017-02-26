package net.bbmsoft.fxtended.annotations.binding.impl

import com.google.common.collect.Lists
import java.util.Collections
import java.util.List
import javafx.css.CssMetaData
import javafx.css.Styleable
import javafx.css.StyleableProperty
import javafx.scene.control.Control
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend.lib.macro.expression.Expression

/**
 *
 * CssMetadataGenerator
 *
 * @author Michael Bachmann
 *
 */
class BindablePropertyCssMetadataHelper {

	final extension ClassNameHelper = new ClassNameHelper

	final String cssMetaDataListName = "cssMetaDataList"
	final String cssInitializedFieldName = "cssInitialized"
	final String initializeCssMethodName = "initializeCss"
	final String getClassCssMetaDataMethodName = "getClassCssMetaData"

	final extension TransformationContext context
	final extension TypeHelper typeHelper

	new(TransformationContext context) {
		this.context = context
		this.typeHelper = new TypeHelper(context)
	}

	def StyleableFieldInfo collectStyleInfo(MutableFieldDeclaration field, String propertyName, String propertyAccessor,
		String metadataName, String selector, Expression initializer, TypeReference classType,
		TypeReference propertyType, TypeReference superType, TypeReference fieldType) {

		val converterInitializer = field.makeConverterInitializer(propertyType)

		if (converterInitializer !== null) {
			val control = classType.isAssignableFrom(Control.newTypeReference)

			new StyleableFieldInfo(propertyName, propertyAccessor, metadataName, selector, initializer, classType,
				propertyType, superType, converterInitializer, control)
		} else {
			null
		}
	}

	def addCssMetadata(MutableClassDeclaration clazz, List<StyleableFieldInfo> infos) {

		infos.forEach [ info |
			clazz.addMetaDataObject(info)
		]

		if (infos.size > 0) {

			val styleableType = Styleable.newTypeReference
			val wildcard = newWildcardTypeReference
			val styleableWildcard = newWildcardTypeReference(styleableType)
			val metaDataType = CssMetaData.newTypeReference(styleableWildcard, wildcard)
			val listType = List.newTypeReference(metaDataType)

			clazz.addMetaDataList

			clazz.addCssInitializedField

			clazz.addInitializeCssMethod(listType, infos)

			clazz.addMetaDataListAccessor(listType)
		}

	}

	private def addMetaDataListAccessor(MutableClassDeclaration clazz, TypeReference listType) {

		val control = Control.newTypeReference.type.isAssignableFrom(clazz)

		clazz.findMethod(getClassCssMetaDataMethodName)?.remove

		clazz.addMethod(getClassCssMetaDataMethodName) [
			static = true
			returnType = listType
			body = ['''return «cssMetaDataListName»;''']
		]

		val getCssMetaDataMethodName = '''get«IF control»Control«ENDIF»CssMetaData'''

		clazz.findMethod(getCssMetaDataMethodName)?.remove

		clazz.addMethod(getCssMetaDataMethodName) [
			returnType = listType
			body = ['''return «getClassCssMetaDataMethodName»();''']
		]
	}

	private def addInitializeCssMethod(MutableClassDeclaration clazz, TypeReference listType,
		List<StyleableFieldInfo> infos) {

		val parentClass = clazz.extendedClass
		val getClassCssMetaData = parentClass.allResolvedMethods.filter[
			declaration.simpleName == getClassCssMetaDataMethodName
		].findFirst[resolvedParameters.empty]

		clazz.findMethod(initializeCssMethodName)?.remove

		clazz.addMethod(initializeCssMethodName) [
			returnType = Boolean.newTypeReference
			visibility = Visibility.PRIVATE
			static = true
			final = true
			body = [
				'''
					«listType.escapedName» temp = «Lists.name».newArrayList(«IF parentClass != Object.newTypeReference»«parentClass.type.simpleName».«getClassCssMetaData?.declaration?.simpleName»()«ENDIF»);
					«infos.map[metadataName].fold("")[a, b|
						'''
						«a»temp.add(«b»);
						''']»
					«cssMetaDataListName» = «Collections.name».unmodifiableList(temp);
					return true;
				'''
			]
		]
	}

	private def addCssInitializedField(MutableClassDeclaration clazz) {

		clazz.findField(cssInitializedFieldName)?.remove

		clazz.addField(cssInitializedFieldName) [
			type = Boolean.newTypeReference
			visibility = Visibility.PRIVATE
			static = true
			final = true
			initializer = ['''«initializeCssMethodName»()''']
		]
	}

	private def addMetaDataList(MutableClassDeclaration clazz) {

		clazz.findField(cssMetaDataListName)?.remove

		clazz.addField(cssMetaDataListName) [
			static = true
			type = List.newTypeReference(
				CssMetaData.newTypeReference(newWildcardTypeReference(Styleable.newTypeReference),
					newWildcardTypeReference))
		]
	}

	private def addMetaDataObject(MutableClassDeclaration clazz, StyleableFieldInfo info) {

		val metaName = info.metadataName

		if (!clazz.hasField(metaName)) {

			clazz.addField(metaName) [
				val actualPropertyType = if (info.propertyType.findType.isNumber)
						Number.newTypeReference
					else
						info.propertyType
				val fieldType = CssMetaData.newTypeReference(info.classType, actualPropertyType)
				val propertyType = StyleableProperty.newTypeReference(actualPropertyType)
				visibility = Visibility.PRIVATE
				final = true
				static = true
				type = fieldType
				initializer = [

					val styleableName = "styleable"

					'''
						new «fieldType.escapedName»(
						"«info.selectorName»", «info.converterInitilizer», «info.defaultValueInitializer») {

						  @Override
						  public boolean isSettable(«info.classType» «styleableName») {
						    return «styleableName».«info.propertyName» == null || !«styleableName».«info.propertyName».isBound();
						  }

						  @Override
						  public «propertyType.escapedName» getStyleableProperty(«info.classType» «styleableName») {
						    return «styleableName».«info.accessorName»;
						  }
						}
					''']
			]
		}
	}

	private def hasField(MutableClassDeclaration it, String fieldName) {
		findField(fieldName) !== null
	}

	private def findField(MutableClassDeclaration it, String fieldName) {
		declaredFields.findFirst[simpleName == fieldName]
	}

	// use only for no-args-methods!
	private def findMethod(MutableClassDeclaration it, String methodName) {
		declaredMethods.findFirst[simpleName == methodName && parameters.size == 0]
	}
}
