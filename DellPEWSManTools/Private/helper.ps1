<#
helper.ps1 - helper functions for public exported commands.

_author_ = Ravikanth Chaganti <Ravikanth_Chaganti@Dell.com> _version_ = 1.0

Copyright (c) 2017, Dell, Inc.

This software is licensed to you under the GNU General Public License, version 2 (GPLv2). There is NO WARRANTY for this software, express or implied, including the implied warranties of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. You should have received a copy of GPLv2 along with this software; if not, see http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt
#>
function TestPossibleValuesContainAttributeValues {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [String[]]$PossibleValues,

        [Parameter(Mandatory)]
        [String[]]$AttributeValues
    )

    foreach ($AttributeValue in $AttributeValues) {
        # iterate over each attribute value and determine if the possible values contains it
        if ( -not ($PossibleValues -contains $AttributeValue)) {
            return $False
        }
    }
    return $True
}