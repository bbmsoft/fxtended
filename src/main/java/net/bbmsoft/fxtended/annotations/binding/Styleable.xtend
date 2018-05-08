package net.bbmsoft.fxtended.annotations.binding

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import javafx.scene.paint.Paint

/**
 * Use on fields annotated with {@link BindableProperty &#064;BindableProperty} to make that property styleable with css.
 * <p>
 * The Xtend compiler will automatically create the required css meta data.
 * <p>
 * Example:
 * <pre>
 * Xtend:
 * <code>
 *   &#064;Styleable("-my-css-property")
 *   &#064;BindableProperty double value = 5;
 * </code>
 * Css:
 * <code>
 *   .item {
 *     -my-css-property: 9;
 *   }
 * </code>
 * </pre>
 * Styleable properties must always have an initializer!
 * <p>
 * Currently supported types:
 * <ul>
 * <li>{@link int}/{@link Integer}</li>
 * <li>float/{@link Float}</li>
 * <li>double/{@link Double}</li>
 * <li>long/{@link Long}</li>
 * <li>boolean/{@link Boolean}</li>
 * <li>{@link String}</li>
 * <li>{@link Paint}</li>
 * </ul>
 * 
 * @author Michael Bachmann
 */
@Target(ElementType.FIELD)
annotation Styleable {String value}