package net.bbmsoft.fxtended.annotations.binding.impl

import javafx.application.Platform
import net.bbmsoft.fxtended.annotations.binding.FXAccessors
import org.eclipse.xtend.lib.annotations.AccessorsProcessor
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.AnnotationTarget
import org.eclipse.xtend.lib.macro.declaration.MutableFieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility

class FXAccessorsProcessor extends AccessorsProcessor {

	static class Util extends AccessorsProcessor.Util {

		final extension TransformationContext context

		new(TransformationContext context) {
			super(context)
			this.context = context
		}

		override getAccessorsAnnotation(extension AnnotationTarget it) {
			FXAccessors.findTypeGlobally.findAnnotation
		}

		override addGetter(MutableFieldDeclaration field, Visibility visibility) {

			field.validateGetter

			field.declaringType.addMethod(field.getterName) [
				primarySourceElement = field.primarySourceElement
				addAnnotation(newAnnotationReference(Pure))
				returnType = field.type.orObject
				body = '''
					if(«field.fieldOwner».getScene() !== null && !«Platform.name».isFxApplicationThread()) {
						throw new «IllegalStateException.name»("Not on JavaFX Application thread. Current thread = " + Thread.currentThread().getName());
					}
					return «field.fieldOwner».«field.simpleName»;'''
				static = field.static
				it.visibility = visibility
			]
		}

		override addSetter(MutableFieldDeclaration field, Visibility visibility) {

			field.validateSetter

			field.declaringType.addMethod(field.setterName) [
				primarySourceElement = field.primarySourceElement
				returnType = primitiveVoid
				val param = addParameter(field.simpleName, field.type.orObject)
				body = '''
					if(«field.fieldOwner».getScene() !== null && !«Platform.name».isFxApplicationThread()) {
						throw new «IllegalStateException.name»("Not on JavaFX Application thread. Current thread = " + Thread.currentThread().getName());
					}
					«field.fieldOwner».«field.simpleName» = «param.simpleName»;'''
				static = field.static
				it.visibility = visibility
			]

		}

		private def fieldOwner(MutableFieldDeclaration it) {
			if(static) declaringType.newTypeReference else "this"
		}

		private def orObject(TypeReference ref) {
			if(ref === null) object else ref
		}

	}

	override protected _transform(MutableFieldDeclaration it, extension TransformationContext context) {

		val extension util = new FXAccessorsProcessor.Util(context)

		if (shouldAddGetter) {
			addGetter(getterType.toVisibility)
		}

		if (shouldAddSetter) {
			addSetter(setterType.toVisibility)
		}
	}
}