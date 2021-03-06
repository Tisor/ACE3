/*
 * Author: PabstMirror
 * Opens the disarm dialog (allowing a person to remove items)
 *
 * Arguments:
 * 0: Caller (player) <OBJECT>
 * 1: Target <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, bob] call ace_disarming_fnc_openDisarmDialog
 *
 * Public: No
 */
#include "script_component.hpp"

#define TEXTURES_RANKS [ \
    "", \
    "\A3\Ui_f\data\GUI\Cfg\Ranks\private_gs.paa", \
    "\A3\Ui_f\data\GUI\Cfg\Ranks\corporal_gs.paa", \
    "\A3\Ui_f\data\GUI\Cfg\Ranks\sergeant_gs.paa", \
    "\A3\Ui_f\data\GUI\Cfg\Ranks\lieutenant_gs.paa", \
    "\A3\Ui_f\data\GUI\Cfg\Ranks\captain_gs.paa", \
    "\A3\Ui_f\data\GUI\Cfg\Ranks\major_gs.paa", \
    "\A3\Ui_f\data\GUI\Cfg\Ranks\colonel_gs.paa" \
    ]

PARAMS_2(_caller,_target);

//Sanity Checks
if (_caller != ACE_player) exitwith {ERROR("Player isn't caller?");};
if (!([_player, _target] call FUNC(canPlayerDisarmUnit))) exitWith {ERROR("Can't Disarm Unit");};
if (dialog) then {ERROR("Dialog open when trying to open disarm dialog"); closeDialog 0;};

disableSerialization;

createDialog QGVAR(remoteInventory);

_display = uiNamespace getVariable ["ACE_remoteInventory", displayNull];
if (isNull _display) exitWith {ERROR("Display is Null");};

GVAR(disarmTarget) = _target;

//Setup Drop Event (on right pannel)
(_display displayCtrl 632) ctrlAddEventHandler ["LBDrop", {
    if (isNull GVAR(disarmTarget)) exitWith {};
    PARAMS_5(_ctrl,_xPos,_yPos,_idc,_itemInfo);
    EXPLODE_3_PVT((_itemInfo select 0),_displayText,_value,_data);

    if (isNull GVAR(disarmTarget)) exitWith {ERROR("disarmTarget is null");};

    TRACE_2("Debug: Droping %1 from %2",_data,GVAR(disarmTarget));
    ["DisarmDropItems", [GVAR(disarmTarget)], [ACE_player, GVAR(disarmTarget), [_data]]] call EFUNC(common,targetEvent);

    false //not sure what this does
}];

//Setup PFEH
[{
    disableSerialization;
    EXPLODE_2_PVT(_this,_args,_pfID);
    EXPLODE_3_PVT(_args,_player,_target,_display);

    if ((!([_player, _target] call FUNC(canPlayerDisarmUnit))) ||
            {isNull _display} ||
            {_player != ACE_player}) then {

        [_pfID] call CBA_fnc_removePerFrameHandler;
        GVAR(disarmTarget) = objNull;
        if (!isNull _display) then {closeDialog 0;}; //close dialog if still open
    } else {
        _groundContainer = _display displayCtrl 632;
        _targetContainer = _display displayCtrl 633;
        _playerName = _display displayCtrl 111;
        _rankPicture = _display displayCtrl 1203;

        //Show rank and name (just like BIS's inventory)
        _rankIndex = ((["PRIVATE", "CORPORAL", "SERGEANT", "LIEUTENANT", "CAPTAIN", "MAJOR", "COLONEL"] find (rank _target)) + 1);
        _rankPicture ctrlSetText (TEXTURES_RANKS select _rankIndex);
        _playerName ctrlSetText ([GVAR(disarmTarget)] call EFUNC(common,getName));

        //Clear both inventory lists:
        lbClear _groundContainer;
        lbClear _targetContainer;

        //Show the items in the ground disarmTarget's inventory
        _targetUniqueItems = [GVAR(disarmTarget)] call FUNC(getAllGearUnit);
        [_targetContainer, _targetUniqueItems] call FUNC(showItemsInListbox);

        //Try to find a holder that the target is using to drop items into:
        _holder = objNull;
        {
            if ((_x getVariable [QGVAR(disarmUnit), objNull]) == _target) exitWith {
                _holder = _x;
            };
        } forEach ((getpos _target) nearObjects [DISARM_CONTAINER, 3]);

        //If a holder exists, show it's inventory
        if (!isNull _holder) then {
            _holderUniqueItems = [_holder] call FUNC(getAllGearContainer);
            [_groundContainer, _holderUniqueItems] call FUNC(showItemsInListbox);
        };
    };
}, 0, [_caller, _target, _display]] call CBA_fnc_addPerFrameHandler;
