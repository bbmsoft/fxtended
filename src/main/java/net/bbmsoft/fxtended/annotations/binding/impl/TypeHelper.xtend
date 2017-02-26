package net.bbmsoft.fxtended.annotations.binding.impl

import javafx.beans.property.BooleanProperty
import javafx.beans.property.DoubleProperty
import javafx.beans.property.FloatProperty
import javafx.beans.property.IntegerProperty
import javafx.beans.property.LongProperty
import javafx.beans.property.ObjectProperty
import javafx.beans.property.ReadOnlyBooleanProperty
import javafx.beans.property.ReadOnlyBooleanWrapper
import javafx.beans.property.ReadOnlyDoubleProperty
import javafx.beans.property.ReadOnlyDoubleWrapper
import javafx.beans.property.ReadOnlyFloatProperty
import javafx.beans.property.ReadOnlyFloatWrapper
import javafx.beans.property.ReadOnlyIntegerProperty
import javafx.beans.property.ReadOnlyIntegerWrapper
import javafx.beans.property.ReadOnlyLongProperty
import javafx.beans.property.ReadOnlyLongWrapper
import javafx.beans.property.ReadOnlyObjectProperty
import javafx.beans.property.ReadOnlyObjectWrapper
import javafx.beans.property.ReadOnlyStringProperty
import javafx.beans.property.ReadOnlyStringWrapper
import javafx.beans.property.SimpleBooleanProperty
import javafx.beans.property.SimpleDoubleProperty
import javafx.beans.property.SimpleFloatProperty
import javafx.beans.property.SimpleIntegerProperty
import javafx.beans.property.SimpleLongProperty
import javafx.beans.property.SimpleObjectProperty
import javafx.beans.property.SimpleStringProperty
import javafx.beans.property.StringProperty
import javafx.css.SimpleStyleableBooleanProperty
import javafx.css.SimpleStyleableDoubleProperty
import javafx.css.SimpleStyleableFloatProperty
import javafx.css.SimpleStyleableIntegerProperty
import javafx.css.SimpleStyleableLongProperty
import javafx.css.SimpleStyleableObjectProperty
import javafx.css.SimpleStyleableStringProperty
import javafx.css.StyleConverter
import javafx.css.StyleableBooleanProperty
import javafx.css.StyleableDoubleProperty
import javafx.css.StyleableFloatProperty
import javafx.css.StyleableIntegerProperty
import javafx.css.StyleableLongProperty
import javafx.css.StyleableObjectProperty
import javafx.css.StyleableStringProperty
import javafx.scene.paint.Paint
import javafx.scene.text.Font
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference

/**
 *
 * TypeHelper
 *
 * @author Michael Bachmann
 *
 */
class TypeHelper {

	final extension ClassNameHelper = new ClassNameHelper
	final extension TransformationContext context

	new(TransformationContext context) {
		this.context = context
	}

	def TypeReference findPublicType(TypeReference it, boolean readOnly, boolean styleable) {

		switch (findType) {
			case DOUBLE:
				{
					if (readOnly)
						ReadOnlyDoubleProperty
					else if (styleable)
						StyleableDoubleProperty
					else
						DoubleProperty
				}.newTypeReference
			case FLOAT:
				{
					if (readOnly)
						ReadOnlyFloatProperty
					else if (styleable)
						StyleableFloatProperty
					else
						FloatProperty
				}.newTypeReference
			case INTEGER:
				{
					if (readOnly)
						ReadOnlyIntegerProperty
					else if (styleable)
						StyleableIntegerProperty
					else
						IntegerProperty
				}.newTypeReference
			case LONG:
				{
					if (readOnly)
						ReadOnlyLongProperty
					else if (styleable)
						StyleableLongProperty
					else
						LongProperty
				}.newTypeReference
			case BOOLEAN:
				{
					if (readOnly)
						ReadOnlyBooleanProperty
					else if (styleable)
						StyleableBooleanProperty
					else
						BooleanProperty
				}.newTypeReference
			case STRING:
				{
					if (readOnly)
						ReadOnlyStringProperty
					else if (styleable)
						StyleableStringProperty
					else
						StringProperty
				}.newTypeReference
			default:
				{
					if (readOnly)
						ReadOnlyObjectProperty
					else if (styleable)
						StyleableObjectProperty
					else
						ObjectProperty
				}.newTypeReference(it)
		}
	}

	def TypeReference findImplType(TypeReference it, boolean readOnly, boolean styleable) {

		switch (findType) {
			case DOUBLE:
				{
					if (readOnly)
						ReadOnlyDoubleWrapper
					else if (styleable)
						SimpleStyleableDoubleProperty
					else
						SimpleDoubleProperty
				}.newTypeReference
			case FLOAT:
				{
					if (readOnly)
						ReadOnlyFloatWrapper
					else if (styleable)
						SimpleStyleableFloatProperty
					else
						SimpleFloatProperty
				}.newTypeReference
			case INTEGER:
				{
					if (readOnly)
						ReadOnlyIntegerWrapper
					else if (styleable)
						SimpleStyleableIntegerProperty
					else
						SimpleIntegerProperty
				}.newTypeReference
			case LONG:
				{
					if (readOnly)
						ReadOnlyLongWrapper
					else if (styleable)
						SimpleStyleableLongProperty
					else
						SimpleLongProperty
				}.newTypeReference
			case BOOLEAN:
				{
					if (readOnly)
						ReadOnlyBooleanWrapper
					else if (styleable)
						SimpleStyleableBooleanProperty
					else
						SimpleBooleanProperty
				}.newTypeReference
			case STRING:
				{
					if (readOnly)
						ReadOnlyStringWrapper
					else if (styleable)
						SimpleStyleableStringProperty
					else
						SimpleStringProperty
				}.newTypeReference
			default:
				{
					if (readOnly)
						ReadOnlyObjectWrapper
					else if (styleable)
						SimpleStyleableObjectProperty
					else
						SimpleObjectProperty
				}.newTypeReference(it)
		}
	}

	def PropertyType findType(TypeReference reference) {

		switch (reference) {
			case Double.newTypeReference.isAssignableFrom(reference): {
				PropertyType.DOUBLE
			}
			case Float.newTypeReference.isAssignableFrom(reference): {
				PropertyType.FLOAT
			}
			case Integer.newTypeReference.isAssignableFrom(reference): {
				PropertyType.INTEGER
			}
			case Long.newTypeReference.isAssignableFrom(reference): {
				PropertyType.LONG
			}
			case Boolean.newTypeReference.isAssignableFrom(reference): {
				PropertyType.BOOLEAN
			}
			case String.newTypeReference.isAssignableFrom(reference): {
				PropertyType.STRING
			}
			case Paint.newTypeReference.isAssignableFrom(reference): {
				PropertyType.PAINT
			}
			case Font.newTypeReference.isAssignableFrom(reference): {
				PropertyType.FONT
			}
			case Enum.newTypeReference.isAssignableFrom(reference): {
				PropertyType.ENUM
			}
			default: {
				PropertyType.OBJECT
			}
		}
	}

	def String makeConverterInitializer(MutableFieldDeclaration field, TypeReference it) {

		val type = findType

		switch (type) {
			case type.isNumber:
				return '''«StyleConverter.name».getSizeConverter()'''
			case BOOLEAN: '''«StyleConverter.name».getBooleanConverter()'''
			case STRING: '''«StyleConverter.name».getStringConverter()'''
			case COLOR: '''«StyleConverter.name».getColorConverter()'''
			case PAINT: '''«StyleConverter.name».getPaintConverter()'''
			case FONT: '''«StyleConverter.name».getFontConverter()'''
			case ENUM: '''«StyleableEnumHelper.name».getEnumConverter(«it.escapedName».class)'''
			default:
				null
		}
	}
}
