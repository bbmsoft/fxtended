package net.bbmsoft.fxtended.annotations.binding.impl

import javafx.application.Platform
import org.eclipse.xtend.lib.macro.AbstractMethodProcessor
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

class OnFXThreadProcessor extends AbstractMethodProcessor {

	override doTransform(MutableMethodDeclaration annotatedMethod, extension TransformationContext context) {

		if (annotatedMethod.returnType.isInferred) {
			annotatedMethod.addWarning("Cannot delegate method with inferred return type. Please specify an explicit return type.")
			return
		} else if (!annotatedMethod.returnType.isVoid) {
			annotatedMethod.addWarning("Cannot delegate non-void method to JavaFX Application Thread.")
			return
		}

		val generatedMethodName = annotatedMethod.findAvailableName('''_«annotatedMethod.simpleName»''')

		annotatedMethod.declaringType.addMethod(generatedMethodName)[
			visibility = Visibility.PRIVATE
			static = false
			final = true
			returnType = annotatedMethod.returnType
			body = annotatedMethod.body
			annotatedMethod.parameters.forEach[p | addParameter(p.simpleName, p.type)]
		]

		annotatedMethod.body = [
		val platform = toJavaCode(Platform.newTypeReference)
		'''
			if(!«platform».isFxApplicationThread()) {
				«platform».runLater(new Runnable() {
					@Override
					public void run() {
						«generatedMethodName»(«annotatedMethod.parameters.map[simpleName].reduce[p1, p2 | '''«p1», «p2»''']»);
					}
				});
			} else {
				«generatedMethodName»(«annotatedMethod.parameters.map[simpleName].reduce[p1, p2 | '''«p1», «p2»''']»);
			}
		''']
	}

	private def String findAvailableName(MutableMethodDeclaration annotatedMethod, String methodName) {

		if(annotatedMethod.declaringType.declaredMethods.findFirst[simpleName == methodName] === null) {
			methodName
		} else {
			annotatedMethod.findAvailableName('''_«methodName»''')
		}
	}
}