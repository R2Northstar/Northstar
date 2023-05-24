// ModSettings_Slider
// since we are missing some utility functions (e.g. GetMax, GetMin, SetValue), this is basically a collection of workarounds.
global struct MS_Slider
{
    var slider
    float min = 0.0
    float max = 1.0
    float stepSize = 0.05
}

globalize_all_functions

MS_Slider function MS_Slider_Setup( var slider, float min = 0.0, float max = 1.0, float startVal = 0.0, float stepSize = 0.05 )
{
    MS_Slider result
    result.slider = slider
    result.min = min
    result.max = max
    result.stepSize = stepSize
    Hud_SliderControl_SetMin( slider, startVal )
    Hud_SliderControl_SetMax( slider, startVal )
    Hud_SliderControl_SetStepSize( slider, stepSize )
    Hud_SliderControl_SetMin( slider, min )
    Hud_SliderControl_SetMax( slider, max )
    return result
}

void function MS_Slider_SetValue( MS_Slider slider, float val )
{
    Hud_SliderControl_SetMin( slider.slider, val )
    Hud_SliderControl_SetMax( slider.slider, val )
    Hud_SliderControl_SetMin( slider.slider, slider.min )
    Hud_SliderControl_SetMax( slider.slider, slider.max )
}

void function MS_Slider_SetMin( MS_Slider slider, float min )
{
    slider.min = min
    Hud_SliderControl_SetMin( slider.slider, min )
}

void function MS_Slider_SetMax( MS_Slider slider, float max )
{
    slider.max = max
    Hud_SliderControl_SetMax( slider.slider, max )
}

void function MS_Slider_SetStepSize( MS_Slider slider, float stepSize )
{
    slider.stepSize = stepSize
    Hud_SliderControl_SetStepSize( slider.slider, stepSize )
}
