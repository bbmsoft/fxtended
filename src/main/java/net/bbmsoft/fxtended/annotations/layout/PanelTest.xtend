package net.bbmsoft.fxtended.annotations.layout

import java.lang.annotation.Target
import net.bbmsoft.fxtended.annotations.layout.impl.PanelTestProcessor
import org.eclipse.xtend.lib.macro.Active

@Target(TYPE)
@Active(PanelTestProcessor)
annotation PanelTest {
}
