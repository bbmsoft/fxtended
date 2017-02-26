package net.bbmsoft.fxtended.annotations.layout

import java.lang.annotation.Target
import net.bbmsoft.fxtended.annotations.layout.impl.FXMLRootProcessor
import org.eclipse.xtend.lib.macro.Active

@Target(TYPE)
@Active(FXMLRootProcessor)
annotation FXMLRoot {
	String value = ''
}