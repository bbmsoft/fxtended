package net.bbmsoft.fxtended.annotations.css

import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.Active
import net.bbmsoft.fxtended.annotations.css.impl.PseudoClassProcessor

@Target(TYPE)
@Active(PseudoClassProcessor)
annotation PseudoClasses {
	String[] value
}