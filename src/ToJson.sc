// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.


ToJSON {
	classvar <nl, <tab;

	*initClass {
		nl = [$\\, $\\, $n].as(String);
		tab = [$\\, $\\, $t].as(String);
	}

	*stringify { | obj |
		var ret;
		
		case
		{ obj.isString } {^obj.asCompileString.replace("\n", this.nl).replace("\t", this.tab) }
		{ obj.class === Symbol} {^this.stringify(obj.asString)}
		{ obj.isNil } { ^"null" }
		{ obj === true } { ^"true" }
		{ obj === false } { ^"false" }
		{ obj.isNumber } {
			case
			{obj.isNaN } { ^"null"}
			{obj == inf } { ^"null"}
			{obj == (-inf)} { ^"null"}
			{ ^obj.asString }
		}
		{ obj.isKindOf(SequenceableCollection) } {
			^"[ % ]".format(this.fromArray(obj));
		}
		{ obj.isKindOf(Dictionary) } { ^this.fromDict(obj)}
		{ obj.isKindOf(Set) } { ^"[ % ]".format(this.fromArray(obj.as(Array)))}
	}

	*fromArray { | obj |
		^obj.collect({ | item |
			this.stringify(item)
		}).join(", ");
	}

	*fromDict { | obj |
		var ret = List.new;
		obj.keysValuesDo({ | key, val |
			ret.add( "%: %".format(key.asString.quote,  this.stringify(val)));
		});
		^"{ % }".format(ret.join(", "));
	}
}