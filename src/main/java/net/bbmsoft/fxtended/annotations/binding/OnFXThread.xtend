package net.bbmsoft.fxtended.annotations.binding

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import javafx.application.Platform
import net.bbmsoft.fxtended.annotations.binding.impl.OnFXThreadProcessor
import org.eclipse.xtend.lib.macro.Active

/**
 * Calls of methods annotated with this annotation will be automatically
 * delegated to the JavaFX Application Thread using
 * {@link Platform#runLater(Runnable)} iff the method is called from any other than the JavaFX Application Thread.
 * 
 * @author Michael Bachmann
 */
@Target(ElementType.METHOD)
@Active(OnFXThreadProcessor)
annotation OnFXThread {
}
