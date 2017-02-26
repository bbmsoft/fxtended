package net.bbmsoft.fxtended.annotations.binding

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import net.bbmsoft.fxtended.annotations.binding.impl.CheckFXThreadProcessor
import org.eclipse.xtend.lib.macro.Active

/**
 * Similar to {@link CheckFXThread} but this version has no effect unless the
 * system property "xtend.compile.check.fx.thread" is set to "true" (case
 * insensitive) during compilation.
 * <p>
 * This annotation is NOT supposed to be used in API methods, but instead is
 * intended to validate everything happens on the correct thread while testing
 * development builds or release candidates.
 * <p>
 * When building an actual release version, the aforementioned system property
 * should not be set, so the thread checking is omitted in the actual build and
 * does not produce any unnecessary runtime overhead.
 * 
 * @author Michael Bachmann
 */
@Target(ElementType.METHOD, ElementType.FIELD)
@Active(CheckFXThreadProcessor)
annotation TestCheckFXThread {
	Class<?> exception = IllegalStateException
	String message = 'Not on JavaFX Application Thread!'
}