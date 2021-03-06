function outStruct = chanLocCreate(nameChan, numChan)

outStruct = struct('labels', nameChan,...
				'type', [],...
				'theta', [],...
				'radius', [],...
				'X', [],...
				'Y', [],...
				'Z', [],...
				'sph_theta', [],...
				'sph_phi', [],...
				'sph_radius', [],...
				'urchan', numChan,...
				'ref', nameChan,...
				'datachan', {0});