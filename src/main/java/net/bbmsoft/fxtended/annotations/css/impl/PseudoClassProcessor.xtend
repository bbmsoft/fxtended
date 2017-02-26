package net.bbmsoft.fxtended.annotations.css.impl

import java.util.List
import java.util.Locale
import javafx.css.PseudoClass
import net.bbmsoft.fxtended.annotations.css.PseudoClasses
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.TransformationParticipant
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

class PseudoClassProcessor implements TransformationParticipant<MutableClassDeclaration> {

	private extension TransformationContext contetxt
	
	override void doTransform(List<? extends MutableClassDeclaration> classes, TransformationContext context) {
		
		this.contetxt = context
		
		classes.forEach[addPseudoClasses]
	}
	
	def addPseudoClasses(MutableClassDeclaration clazz) {
		
		val annotation = clazz.findAnnotation(PseudoClasses.newTypeReference.type)
		val pseudoClasses = annotation.getStringArrayValue('value')
		
		pseudoClasses.forEach[clazz.addPseudoClass(it)]
	}
	
	def addPseudoClass(MutableClassDeclaration clazz, String string) {
		
		clazz.addField('''PSEUDO_CLASS_«string.replace('-', '_').toUpperCase(Locale.US)»''')[
			visibility = Visibility.PRIVATE
			static = true
			final = true
			type = PseudoClass.newTypeReference
			initializer = ['''javafx.css.PseudoClass.getPseudoClass("«string»")''']
		]
	}
	
}