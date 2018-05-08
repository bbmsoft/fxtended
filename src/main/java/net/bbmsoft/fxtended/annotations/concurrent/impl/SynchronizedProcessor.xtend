package net.bbmsoft.fxtended.annotations.concurrent.impl

import net.bbmsoft.fxtended.annotations.concurrent.Synchronized
import org.eclipse.xtend.lib.macro.AbstractMethodProcessor
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableTypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

class SynchronizedProcessor extends AbstractMethodProcessor {

	override doTransform(MutableMethodDeclaration annotatedMethod, extension TransformationContext context) {

		val syncAnnotationType = findTypeGlobally(Synchronized)
		val syncAnnotation = annotatedMethod.findAnnotation(syncAnnotationType)

		if(annotatedMethod.isAbstract) {
			syncAnnotation.addError('Abstract methods cannot be synchronized.')
			return
		}

		val value = syncAnnotation.getValue('value').toString

		val objectSync = value.trim.isEmpty

		annotatedMethod.synchronized = objectSync
		if (objectSync) {
			return
		}

		if(annotatedMethod.isDefault) {
			syncAnnotation.addError('Default methods cannot be synchronized on a field.')
			return
		}

		val methodName = annotatedMethod.simpleName.enhanceMethodName(annotatedMethod.declaringType)

		annotatedMethod.declaringType.addMethod(methodName) [
			visibility = Visibility.PRIVATE
			static = annotatedMethod.static
			final = annotatedMethod.final
			returnType = annotatedMethod.returnType
			body = annotatedMethod.body
		]

		annotatedMethod.body = '''
			synchronized(this.«value») {
				«IF annotatedMethod.returnType != primitiveVoid»return «ENDIF»this.«methodName»(«annotatedMethod.parameters.map[simpleName].reduce['''«$0», «$1»''']»);
			}
		'''
	}

	private def String enhanceMethodName(String string, MutableTypeDeclaration type) {

		if (!type.declaredMethods.map[simpleName].toList.contains(string)) {
			string
		} else {
			'''_«string.enhanceMethodName(type)»'''
		}
	}

}
