package net.bbmsoft.fxtended.annotations.binding

import java.lang.annotation.ElementType
import java.lang.annotation.Target

/**
 * Use on fields annotated with &#064;{@link BindableProperty} to indicate that this property should be read only.
 * 
 * @author Michael Bachmann
 */
@Target(ElementType.FIELD)
annotation ReadOnly {}