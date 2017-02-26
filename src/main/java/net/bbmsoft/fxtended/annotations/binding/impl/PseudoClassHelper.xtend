package net.bbmsoft.fxtended.annotations.binding.impl

import java.util.Locale
import javafx.css.PseudoClass
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.FieldDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableTypeDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility

class PseudoClassHelper {

	final extension TransformationContext context
	
	new(TransformationContext context) {
		this.context = context
	}
	
	def addPseudoClass(MutableTypeDeclaration clazz, FieldDeclaration field, String pseudoClassReference) {

		val pseudoClassName = transformPseudoClassName(pseudoClassReference)

		if (!clazz.declaredFields.filter[simpleName == pseudoClassName].empty) {
			field.addError('''Name clash: generated field «pseudoClassName» already exists.''')
		} else {
			clazz.addField(pseudoClassName) [
				visibility = Visibility.PRIVATE
				static = true
				final = true
				type = PseudoClass.newTypeReference
				initializer = ['''javafx.css.PseudoClass.getPseudoClass("«pseudoClassReference»")''']
			]
		}
	}

	def String transformPseudoClassName(String string) {
		'''PSEUDO_CLASS_«string.toUpperCase(Locale.US).replace('-', '_')»'''
	}

}