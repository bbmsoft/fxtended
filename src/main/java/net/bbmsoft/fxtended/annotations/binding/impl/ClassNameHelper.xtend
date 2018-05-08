package net.bbmsoft.fxtended.annotations.binding.impl

import org.eclipse.xtend.lib.macro.declaration.Type
import org.eclipse.xtend.lib.macro.declaration.TypeReference

class ClassNameHelper {
	
	def escape(String className) {
		className.replace('$', '.')
	}
	
	def escapedName(TypeReference type) {
		type.name.escape
	}
	
	def escapedName(Class<?> type) {
		type.name.escape
	}
	
	def escapedName(Type type) {
		type.qualifiedName.escape
	}
}