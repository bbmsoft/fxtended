package net.bbmsoft.fxtended.annotations.binding.impl

import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.expression.Expression
import org.eclipse.xtend.lib.annotations.Data

@Data
class StyleableFieldInfo {
	
	String propertyName
	String accessorName
	String metadataName
	String selectorName
	Expression defaultValueInitializer
	TypeReference classType
	TypeReference propertyType
	TypeReference superClass
	String converterInitilizer
	boolean control
}