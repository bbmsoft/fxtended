package net.bbmsoft.fxtended.annotations.layout.impl

import java.net.URL
import java.util.Locale
import javafx.fxml.FXMLLoader
import javafx.fxml.Initializable
import net.bbmsoft.fxtended.annotations.layout.FXMLRoot
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.CompilationStrategy
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

class FXMLRootProcessor extends AbstractClassProcessor {

	override doTransform(MutableClassDeclaration it, extension TransformationContext context) {

		generateConstructors(context)
		if(!implementedInterfaces.toList.contains(Initializable.newTypeReference)) {
			implementedInterfaces = implementedInterfaces + #[Initializable.newTypeReference]
		}

//
//		val initializeMethodName = 'initialize'
//
//		if(declaredMethods.findFirst[isInitializeMethod(initializeMethodName, context)] === null) {
//			addMethod(initializeMethodName)[
//				visibility = Visibility.PUBLIC
//				static = false
//				final = true
//				returnType = primitiveVoid
//				addParameter('location', URL.newTypeReference)
//				addParameter('resources', ResourceBundle.newTypeReference)
//				body = ['']
//			]
//		}
	}

//	private def isInitializeMethod(MethodDeclaration it, String initializeMethodName, extension TransformationContext context) {
//
//		simpleName == initializeMethodName
//		&& parameters.size == 2
//		&& parameters.get(0).type.isAssignableFrom(URL.newTypeReference)
//		&& parameters.get(1).type.isAssignableFrom(ResourceBundle.newTypeReference)
//		&& isThePrimaryGeneratedJavaElement
//	}

	private def void generateConstructors(MutableClassDeclaration it, extension TransformationContext context) {

		val explicitConstructos = declaredConstructors.filter[isThePrimaryGeneratedJavaElement]

		val noArgConstructors = explicitConstructos.filter[parameters.size == 0]

		if (noArgConstructors.size == 0) {
			addConstructor(context, explicitConstructos.size != noArgConstructors.size)
		} else {
			noArgConstructors.forEach [
				addError = '''Constructor will be generated automatically! Use 'initialize()' method for customized initialization. '''
			]
		}

		explicitConstructos.toList => [
			removeAll(noArgConstructors.toList)
			forEach[if(!body.toString.contains('this()')) {
				addWarning('''Constructor does not explicitly call 'this()'. No FXML will content be loaded!''')
			}]
		]
	}

	private def void addConstructor(MutableClassDeclaration it, extension TransformationContext context, boolean privateConstructor) {

		addConstructor [ c |

			val annotation = findAnnotation(FXMLRoot.newTypeReference.type)
			val path = annotation.getStringValue('value')

			c.body = constructorBody(path, context)
			c.visibility = if(privateConstructor) Visibility.PRIVATE else Visibility.PUBLIC
		]
	}

	private def CompilationStrategy constructorBody(MutableClassDeclaration it, String path,
		extension TransformationContext context) {

		[ ctx |
			'''
				«FXMLLoader.name» loader = new «FXMLLoader.name»();

				«URL.name» location = «simpleName».class.getResource("«completePath(path)»");

				if(location == null) {
					throw new «IllegalStateException.name»("Cannot find FXML file '«path»'!");
				}

				loader.setLocation(location);
				loader.setRoot(this);
				loader.setController(this);

				try{
					loader.load();
				} catch(java.io.IOException e) {
					System.err.println("Error loading FXML file '«path»':");
					e.printStackTrace();
				}
			'''
		]
	}

	private def String completePath(MutableClassDeclaration it, String path) {

		if(path.trim.empty) {
			'''«simpleName».fxml'''
		} else if(path.toLowerCase(Locale.US).endsWith('.fxml') || path.toLowerCase(Locale.US).endsWith('.xml')) {
			path
		} else {
			'''«path».fxml'''
		}
	}
}