package net.bbmsoft.fxtended.annotations.layout.impl

import java.util.concurrent.BlockingQueue
import java.util.concurrent.LinkedBlockingQueue
import javafx.application.Application
import javafx.application.Platform
import javafx.scene.Parent
import javafx.scene.Scene
import javafx.stage.Stage
import net.bbmsoft.fxtended.annotations.layout.PanelTest
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

class PanelTestProcessor extends AbstractClassProcessor {

	override doTransform(MutableClassDeclaration it, extension TransformationContext context) {

		val clazz = simpleName
		val annotation = findAnnotation(findTypeGlobally(PanelTest))
		val parentTRef = Parent.newTypeReference

		if (!parentTRef.isAssignableFrom(it.newTypeReference)) {
			annotation.addError('''PanelTest can only be used on classes derived from «Parent»''')
			return
		}

		if (declaredMethods.exists[simpleName == 'main']) {
			annotation.addError('''This class already contains a method called 'main'.''')
			return
		}

		addMethod('main') [
			visibility = Visibility.PUBLIC
			static = true
			addParameter('args', newArrayTypeReference(String.newTypeReference))
			body = [

				val application = toJavaCode(Application.newTypeReference)
				val testApp = toJavaCode(TestApp.newTypeReference)
				val thread = toJavaCode(Thread.newTypeReference)
				val stage = toJavaCode(Stage.newTypeReference)
				val interruptedException = toJavaCode(InterruptedException.newTypeReference)
				val platform = toJavaCode(Platform.newTypeReference)

				'''
					
					new «thread»(() -> «application».launch(«testApp».class)).start();
					
					try {
						«stage» stage = «testApp».stageQueue.take();
						«platform».runLater(() -> «testApp».setRoot(stage, new «clazz»()));
					} catch («interruptedException» e) {
						return;
					}
				'''
			]
		]
	}

	static class TestApp extends Application {

		public static final BlockingQueue<Stage> stageQueue = new LinkedBlockingQueue

		override start(Stage primaryStage) throws Exception {
			TestApp.stageQueue.add = primaryStage
		}

		static def setRoot(Stage stage, Parent root) {
			stage.scene = new Scene(root)
			stage.show
		}

	}
}
