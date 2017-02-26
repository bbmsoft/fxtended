package net.bbmsoft.fxtended.annotations.concurrent

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import net.bbmsoft.fxtended.annotations.concurrent.impl.SynchronizedProcessor
import org.eclipse.xtend.lib.macro.Active

@Target(ElementType.METHOD)
@Active(SynchronizedProcessor)
annotation Synchronized {
	String value = ''
}
