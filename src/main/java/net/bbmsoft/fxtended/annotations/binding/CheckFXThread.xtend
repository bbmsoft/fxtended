package net.bbmsoft.fxtended.annotations.binding

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import net.bbmsoft.fxtended.annotations.binding.impl.CheckFXThreadProcessor
import org.eclipse.xtend.lib.macro.Active

/**
 * Instructs the Xtend compiler to create a check whether the annotated method
 * is called from the JavaFX Application Thread.
 * <p>
 * This annotation is supposed to be used in API methods to keep potential users
 * from calling non-threadsafe UI functions from the wrong thread.
 * <p>
 * If you want to verify your application works on the correct threads
 * internally (in non-API methods) consider using {@link TestCheckFXThread}
 * instead, which can be configured to produce the according checks only when
 * compiling test builds but not for releases, reducing the resulting overhead.
 * 
 * @author Michael Bachmann
 */
@Target(ElementType.METHOD, ElementType.FIELD)
@Active(CheckFXThreadProcessor)
annotation CheckFXThread {
	Class<?> exception = IllegalStateException
	String message = 'Not on JavaFX Application Thread!'
}