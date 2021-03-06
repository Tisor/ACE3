/*
 * Author: commy2
 * Handles the climb animation finishing.  Called from "AnimDone" event handler.
 *
 * Arguments:
 * 0: The Unit (usually the player) <OBJECT>
 * 1: The finisehd animation <STRING>
 *
 * Return Value:
 * Nothing
 *
 * Example:
 * [player, "ACE_climb"] call ace_movement_fnc_handleClimb
 *
 * Public: No
 */
#include "script_component.hpp"

private ["_unit", "_anim", "_pos"];

_unit = _this select 0;
_anim = _this select 1;

_pos = _unit modelToWorldVisual (_unit selectionPosition "camera");
[_unit, "AmovPknlMstpSnonWnonDnon", 2] call EFUNC(common,doAnimation);

_pos = _pos vectorDiff (_unit selectionPosition "camera");

_unit setPos _pos;
