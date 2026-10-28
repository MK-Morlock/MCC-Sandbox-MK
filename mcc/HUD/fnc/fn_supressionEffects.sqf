/*================================================================MCC_fnc_supressionEffects================================================================================
  Effects of being supressed / shot at
  IN <>
    0: NUMBER ratio (0.5..1, how close the round passed)
    1: NUMBER direction to the shooter, relative to the player

  Suppression strength (GitHub #59): MCC_suppressionLevel 1 = Minimal, 2 = Average, 3 = Maximum (the original effect).
  Set by the CBA setting "Suppression strength", the In-Game UI module, or Zeus UI Settings.
  Blur, red tint and camera shake are only shown while "Suppression Effects" (MCC_suppressionOn) is on.
  The Arcade fire-direction indicator follows "Fire Direction indicator" (MCC_hitRadar) on its own.

  This file used to start with "if (true) exitWith {}" (all effects disabled). Part of the reason: when suppression was
  off, a colour-correction effect was still created and enabled on every near miss and never destroyed. Effects are now
  only created when they are shown, and always destroyed.
*/
params [["_ratio",0.5,[0]],["_dir",0,[0]]];

//Values can arrive as text from an Eden module ("0", "false"): turn them into a number / true-false first
private _radar = missionNamespace getVariable ["MCC_hitRadar",0];
if (_radar isEqualType "") then {_radar = parseNumber _radar};
if (_radar isEqualType true) then {_radar = [2, 0] select _radar};
if !(_radar isEqualType 0) then {_radar = 0};
private _suppressionOn = missionNamespace getVariable ["MCC_suppressionOn",false];
if (_suppressionOn isEqualType "") then {_suppressionOn = toLower _suppressionOn in ["true", "1"]};
if (_suppressionOn isEqualType 0) then {_suppressionOn = _suppressionOn > 0};
if !(_suppressionOn isEqualType true) then {_suppressionOn = false};

//Arcade hit direction indicator (independent of suppression)
if (_radar == 1) then {
	private _layer = switch (true) do {
		case (_dir > 315 || _dir <= 45): {"MCC_rssHitUp"};
		case (_dir > 45 && _dir <= 135): {"MCC_rssHitRight"};
		case (_dir > 135 && _dir <= 225): {"MCC_rssHitDown"};
		default {"MCC_rssHitLeft"};
	};
	([_layer] call BIS_fnc_rscLayer) cutRsc [_layer, "PLAIN"];
};

if (!_suppressionOn) exitWith {};

// [blur, tint, shake] multipliers per level
private _level = missionNamespace getVariable ["MCC_suppressionLevel",3];
if !(_level isEqualType 0) then {_level = 3};
(switch (round _level) do {
	case 1: {[0.25, 0.35, 0.15]};
	case 2: {[0.6, 0.65, 0.5]};
	default {[1, 1, 1]};
}) params ["_blurMul","_tintMul","_shakeMul"];

_ratio = _ratio * (missionNamespace getVariable ["MCC_supressionEffectsForce",1]);

// Red tint, brighter on the side the fire comes from when "Realistic" direction is on
private _colorCorrectionEffect = ppEffectCreate ["ColorCorrections", 12399];
if (_colorCorrectionEffect isEqualType 0 && {_colorCorrectionEffect != -1}) then {
	private _i = (_ratio min 0.2) * _tintMul;
	private _rect = if (_radar == 0) then {
		switch (true) do {
			case (_dir > 315 || _dir <= 45): {[0.9,0.9,0,0,_i,0.6,0.95]};
			case (_dir > 45 && _dir <= 135): {[0.9,0.9,0,-_i,0,0.6,0.95]};
			case (_dir > 135 && _dir <= 225): {[0.9,0.9,0,0,-_i,0.6,0.95]};
			default {[0.9,0.9,0,_i,0,0.6,0.95]};
		}
	} else {[0.9,0.9,0,0,0,0.6,0.95]};
	_colorCorrectionEffect ppEffectForceInNVG true;
	_colorCorrectionEffect ppEffectEnable true;
	_colorCorrectionEffect ppEffectAdjust [1 - 0.9 * _tintMul,1,0, [0,0,0.5 * _tintMul,0],[0,0,0,1],[0,0,0,1],_rect];
	_colorCorrectionEffect ppEffectCommit 0;
};

// Blur
private _blurEffects = ppEffectCreate ["DynamicBlur", 440];
if (_blurEffects isEqualType 0 && {_blurEffects != -1}) then {
	_blurEffects ppEffectForceInNVG true;
	_blurEffects ppEffectAdjust [_ratio * _blurMul];
	_blurEffects ppEffectEnable true;
	_blurEffects ppEffectCommit 0;
};

// Camera shake
enableCamShake true;
resetCamShake;
addCamShake [(_ratio * 5 * _shakeMul), _ratio, _ratio * 80 * _shakeMul];

sleep 0.5;
{if (_x isEqualType 0 && {_x != -1}) then {ppEffectDestroy _x}} forEach [_blurEffects, _colorCorrectionEffect];
