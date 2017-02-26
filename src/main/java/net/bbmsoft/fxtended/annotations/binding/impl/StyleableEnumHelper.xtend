package net.bbmsoft.fxtended.annotations.binding.impl

import com.sun.javafx.css.converters.EnumConverter
import javafx.css.StyleConverter

/**
 *
 * StyleableEnumHelper
 *
 * @author Michael Bachmann
 *
 */
@SuppressWarnings("restriction")
class StyleableEnumHelper {

	def static <E extends Enum<E>> StyleConverter<String, E> getEnumConverter(Class<E> enumClass) {
		val converter = new EnumConverter<E>(enumClass);
		return converter;
	}
}
