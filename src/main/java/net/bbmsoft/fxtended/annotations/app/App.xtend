package net.bbmsoft.fxtended.annotations.app

import java.lang.annotation.Target
import javafx.application.Application
import net.bbmsoft.fxtended.annotations.app.impl.AppProcessor
import org.eclipse.xtend.lib.macro.Active

/**
 * Turns a class into a JavaFX Application. The class will automatically extend
 * {@link Application} and get a {@code main(String[] args)} method launching
 * the Application.
 */
@Target(TYPE)
@Active(AppProcessor)
annotation App {
}
