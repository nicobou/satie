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


~name = \envfol;
~description = "Envelope follower (audio rate)";

~function = {|in = 0, decaycoeff = 0.99, amp = 2.0, lag = 10 |
	var env, out;
	in.scope;
	env = EnvFollow.ar(LPF(in, 10), decaycoeff, mul: amp, );
	env.scope;
	out = Lag.ar(K2A.ar(env), lag);
	out.scope;
	out;
};
