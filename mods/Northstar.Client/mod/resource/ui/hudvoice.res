"Resource/UI/HudVoice.res"
{
	VoiceSafeArea // Normal SafeArea couldn't be found
	{
		ControlName		ImagePanel
		wide			%90
		tall			%90
		visible			1
		scaleImage		1
		fillColor		"0 0 0 0"
		drawColor		"0 0 0 0"

		pin_to_sibling				Screen
		pin_corner_to_sibling		CENTER
		pin_to_sibling_corner		CENTER
	}

	voiceMic0
	{
		ControlName			ImagePanel
		wide				36
		tall				36
		visible				0
		image				"ui/icon_mic_active"
		scaleImage			1
		zpos				900

		pin_to_sibling				VoiceSafeArea
		pin_corner_to_sibling		TOP_RIGHT
		pin_to_sibling_corner		TOP_RIGHT
	}
	voiceName0
	{
		ControlName			Label
		wide				450
		tall				36
		visible				0
		font				Default_21_ShadowGlow
		textAlignment		east
		textinsetx			13
		zpos				900

		pin_to_sibling				voiceMic0
		pin_corner_to_sibling		TOP_RIGHT
		pin_to_sibling_corner		TOP_LEFT
	}

	voiceMic1
	{
		ControlName			ImagePanel
		wide				36
		tall				36
		visible				0
		image				"ui/icon_mic_active"
		scaleImage			1
		zpos				900

		pin_to_sibling				voiceMic0
		pin_corner_to_sibling		TOP_RIGHT
		pin_to_sibling_corner		BOTTOM_RIGHT
	}
	voiceName1
	{
		ControlName			Label
		wide				450
		tall				36
		visible				0
		font				Default_21_ShadowGlow
		textAlignment		east
		textinsetx			13
		zpos				900

		pin_to_sibling				voiceMic1
		pin_corner_to_sibling		TOP_RIGHT
		pin_to_sibling_corner		TOP_LEFT
	}

	voiceMic2
	{
		ControlName			ImagePanel
		wide				36
		tall				36
		visible				0
		image				"ui/icon_mic_active"
		scaleImage			1
		zpos				900

		pin_to_sibling				voiceMic1
		pin_corner_to_sibling		TOP_RIGHT
		pin_to_sibling_corner		BOTTOM_RIGHT
	}
	voiceName2
	{
		ControlName			Label
		wide				450
		tall				36
		visible				0
		font				Default_21_ShadowGlow
		textAlignment		east
		textinsetx			13
		zpos				900

		pin_to_sibling				voiceMic2
		pin_corner_to_sibling		TOP_RIGHT
		pin_to_sibling_corner		TOP_LEFT
	}

	voiceMic3
	{
		ControlName			ImagePanel
		wide				36
		tall				36
		visible				0
		image				"ui/icon_mic_active"
		scaleImage			1
		zpos				900

		pin_to_sibling				voiceMic2
		pin_corner_to_sibling		TOP_RIGHT
		pin_to_sibling_corner		BOTTOM_RIGHT
	}
	voiceName3
	{
		ControlName			Label
		wide				450
		tall				36
		visible				0
		font				Default_21_ShadowGlow
		textAlignment		east
		textinsetx			13
		zpos				900

		pin_to_sibling				voiceMic3
		pin_corner_to_sibling		TOP_RIGHT
		pin_to_sibling_corner		TOP_LEFT
	}

	voiceMic4
	{
		ControlName			ImagePanel
		wide				36
		tall				36
		visible				0
		image				"ui/icon_mic_active"
		scaleImage			1
		zpos				900

		pin_to_sibling				voiceMic3
		pin_corner_to_sibling		TOP_RIGHT
		pin_to_sibling_corner		BOTTOM_RIGHT
	}
	voiceName4
	{
		ControlName			Label
		wide				450
		tall				36
		visible				0
		font				Default_21_ShadowGlow
		textAlignment		east
		textinsetx			13
		zpos				900

		pin_to_sibling				voiceMic4
		pin_corner_to_sibling		TOP_RIGHT
		pin_to_sibling_corner		TOP_LEFT
	}

	voiceMic5
	{
		ControlName			ImagePanel
		wide				36
		tall				36
		visible				0
		image				"ui/icon_mic_active"
		scaleImage			1
		zpos				900

		pin_to_sibling				voiceMic4
		pin_corner_to_sibling		TOP_RIGHT
		pin_to_sibling_corner		BOTTOM_RIGHT
	}
	voiceName5
	{
		ControlName			Label
		wide				450
		tall				36
		visible				0
		font				Default_21_ShadowGlow
		textAlignment		east
		textinsetx			13
		zpos				900

		pin_to_sibling				voiceMic5
		pin_corner_to_sibling		TOP_RIGHT
		pin_to_sibling_corner		TOP_LEFT
	}

	voiceMic6
	{
		ControlName			ImagePanel
		wide				36
		tall				36
		visible				0
		image				"ui/icon_mic_active"
		scaleImage			1
		zpos				900

		pin_to_sibling				voiceMic5
		pin_corner_to_sibling		TOP_RIGHT
		pin_to_sibling_corner		BOTTOM_RIGHT
	}
	voiceName6
	{
		ControlName			Label
		wide				450
		tall				36
		visible				0
		font				Default_21_ShadowGlow
		textAlignment		east
		textinsetx			13
		zpos				900

		pin_to_sibling				voiceMic6
		pin_corner_to_sibling		TOP_RIGHT
		pin_to_sibling_corner		TOP_LEFT
	}

	voiceMic7
	{
		ControlName			ImagePanel
		wide				36
		tall				36
		visible				0
		image				"ui/icon_mic_active"
		scaleImage			1
		zpos				900

		pin_to_sibling				voiceMic6
		pin_corner_to_sibling		TOP_RIGHT
		pin_to_sibling_corner		BOTTOM_RIGHT
	}
	voiceName7
	{
		ControlName			Label
		wide				450
		tall				36
		visible				0
		font				Default_21_ShadowGlow
		textAlignment		east
		textinsetx			13
		zpos				900

		pin_to_sibling				voiceMic7
		pin_corner_to_sibling		TOP_RIGHT
		pin_to_sibling_corner		TOP_LEFT
	}

	voiceMic8
	{
		ControlName			ImagePanel
		wide				36
		tall				36
		visible				0
		image				"ui/icon_mic_active"
		scaleImage			1
		zpos				900

		pin_to_sibling				voiceMic7
		pin_corner_to_sibling		TOP_RIGHT
		pin_to_sibling_corner		BOTTOM_RIGHT
	}
	voiceName8
	{
		ControlName			Label
		wide				450
		tall				36
		visible				0
		font				Default_21_ShadowGlow
		textAlignment		east
		textinsetx			13
		zpos				900

		pin_to_sibling				voiceMic8
		pin_corner_to_sibling		TOP_RIGHT
		pin_to_sibling_corner		TOP_LEFT
	}

	voiceMic9
	{
		ControlName			ImagePanel
		wide				36
		tall				36
		visible				0
		image				"ui/icon_mic_active"
		scaleImage			1
		zpos				900

		pin_to_sibling				voiceMic8
		pin_corner_to_sibling		TOP_RIGHT
		pin_to_sibling_corner		BOTTOM_RIGHT
	}
	voiceName9
	{
		ControlName			Label
		wide				450
		tall				36
		visible				0
		font				Default_21_ShadowGlow
		textAlignment		east
		textinsetx			13
		zpos				900

		pin_to_sibling				voiceMic9
		pin_corner_to_sibling		TOP_RIGHT
		pin_to_sibling_corner		TOP_LEFT
	}
}
