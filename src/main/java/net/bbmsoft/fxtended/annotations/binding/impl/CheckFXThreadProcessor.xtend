package net.bbmsoft.fxtended.annotations.binding.impl

import java.util.List
import javafx.application.Platform
import javafx.scene.Node
import net.bbmsoft.fxtended.annotations.binding.CheckFXThread
import net.bbmsoft.fxtended.annotations.binding.TestCheckFXThread
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.declaration.MutableMemberDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility

class CheckFXThreadProcessor implements TransformationParticipant<MutableMemberDeclaration> {

	override doTransform(List<? extends MutableMemberDeclaration> elements, extension TransformationContext context) {
		elements.forEach[if(it !== null) transform(context)]
	}

	private def dispatch void transform(MutableMemberDeclaration it, extension TransformationContext context) {
		// ignore
	}

	private def dispatch void transform(MutableMethodDeclaration annotatedMethod, extension TransformationContext context) {
		
		if(annotatedMethod.findAnnotation(findTypeGlobally(TestCheckFXThread)) !== null && !'true'.equalsIgnoreCase(System.getProperty('fxtended.compile.check.fx.thread'))) {
			return
		}

		if(!Node.newTypeReference.type.isAssignableFrom(annotatedMethod.declaringType)) {
			annotatedMethod.addWarning('''Annotation «CheckFXThread.simpleName» has no effect on classes that are not derived from «Node.name»''')
			return
		}

		if(annotatedMethod.returnType === null) {
			annotatedMethod.addWarning('''Cannot add thread check on Method with inferred return type. Please specify explicit return type!''')
			return
		}

		val generatedMethodName = annotatedMethod.findAvailableName('''_«annotatedMethod.simpleName»''')

		val type = annotatedMethod.declaringType
		type.addMethod(generatedMethodName)[
			visibility = Visibility.PRIVATE
			static = false
			final = true
			returnType = annotatedMethod.returnType
			body = annotatedMethod.body
			annotatedMethod.parameters.forEach[p | addParameter(p.simpleName, p.type)]
		]

		val annotation = annotatedMethod.findAnnotation(CheckFXThread.newTypeReference.type)
		val exceptionType = annotation.getValue('exception') as TypeReference
		val exceptionMessage = annotation.getValue('message').toString

		annotatedMethod.body = ['''
			if(«type.simpleName».this.getScene() != null && !«Platform.name».isFxApplicationThread()) {
				throw new «exceptionType»("«exceptionMessage» Current thread = " + Thread.currentThread().getName());
			}
			«IF annotatedMethod.returnType != primitiveVoid && !Void.newTypeReference.isAssignableFrom(annotatedMethod.returnType)»return «ENDIF»«generatedMethodName»(«annotatedMethod.parameters.map[simpleName].reduce[p1, p2 | '''«p1», «p2»''']»);
		''']
		annotatedMethod.final = true
	}

	private def String findAvailableName(MutableMethodDeclaration annotatedMethod, String methodName) {

		if(annotatedMethod.declaringType.declaredMethods.findFirst[simpleName == methodName] === null) {
			methodName
		} else {
			annotatedMethod.findAvailableName('''_«methodName»''')
		}
	}

}