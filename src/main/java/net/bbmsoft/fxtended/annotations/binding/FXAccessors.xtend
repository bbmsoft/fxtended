package net.bbmsoft.fxtended.annotations.binding

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import net.bbmsoft.fxtended.annotations.binding.impl.FXAccessorsProcessor
import org.eclipse.xtend.lib.annotations.AccessorType
import org.eclipse.xtend.lib.macro.Active

/**
 * Instructs the Xtend compiler to create a check whether the annotated method is called
 * from the JavaFX Application Thread.
 *
 * @author Michael Bachmann
 */
@Target(ElementType.METHOD, ElementType.FIELD)
@Active(FXAccessorsProcessor)
annotation FXAccessors {
	Class<?> exception = IllegalStateException
	String message = 'Not on JavaFX Application Thread!'
	AccessorType[] value = #[AccessorType.PUBLIC_GETTER, AccessorType.PUBLIC_SETTER]
}