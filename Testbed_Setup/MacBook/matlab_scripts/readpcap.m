classdef readpcap < handle
    %READPCAP Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        fid;
        global_header;
        prev_len;
    end
    
    methods
        function open(obj, filename)
            obj.fid = fopen(filename);
            
            % should be 0xA1B2C3D4
            obj.global_header.magic_number = fread(obj.fid, 1, '*uint32');

            % major version number
            obj.global_header.version_major = fread(obj.fid, 1, '*uint16');

            % minor version number
            obj.global_header.version_minor = fread(obj.fid, 1, '*uint16');

            % GMT to local correction
            obj.global_header.thiszone = fread(obj.fid, 1, '*int32');

            % accuracy of timestamps
            obj.global_header.sigfigs = fread(obj.fid, 1, '*uint32');

            % max length of captured packets, in octets
            obj.global_header.snaplen = fread(obj.fid, 1, '*uint32');

            % data link type
            obj.global_header.network = fread(obj.fid, 1, '*uint32');
        end
        
        function frame = next(obj)
            % timestamp seconds
            frame.header.ts_sec = fread(obj.fid, 1, '*uint32');

            % timestamp microseconds
            frame.header.ts_usec = fread(obj.fid, 1, '*uint32');

            % number of octets of packet saved in file
            frame.header.incl_len = fread(obj.fid, 1, '*uint32');

            % actual length of packet
            frame.header.orig_len = fread(obj.fid, 1, '*uint32');

            if isempty(frame.header.incl_len)
                frame = [];
                return;
            end

%             % packet data
%             if (mod(frame.header.incl_len,4)==0)
%                 frame.payload = fread(obj.fid, frame.header.incl_len/4, '*uint32');
%             else
%                 frame.payload = fread(obj.fid, frame.header.incl_len, '*uint8');
%             end

            % packet data decoding
            if (mod(frame.header.incl_len,4)==0)
                % fake IPv4 info like mac address etc
                frame.payload_info.fakeinfo = fread(obj.fid, 21, '*uint16');

                % magic bytes
                frame.payload_info.magicbytes = fread(obj.fid, 1, '*uint16');

                % rssi
                frame.payload_info.rssi = fread(obj.fid, 1, '*uint8');

                % fc
                frame.payload_info.frametype = fread(obj.fid, 1, '*uint8');

                % src mac addr
                frame.payload_info.srcmacaddr = fread(obj.fid, 3, '*uint16');

                % sequence number
                frame.payload_info.seqnum = fread(obj.fid, 1, '*uint16');

                % core and spatial stream number
                frame.payload_info.corespatialnumber = fread(obj.fid, 1, '*uint16');

                % channel spec
                frame.payload_info.channelspec = fread(obj.fid, 1, '*uint16');

                % chip version
                frame.payload_info.chipversion = fread(obj.fid, 1, '*uint16');

                frame.payload_CSIs = fread(obj.fid, frame.header.incl_len/4-15, '*uint32');
            else
                frame.payload = fread(obj.fid, frame.header.incl_len, '*uint8');
            end



        end
        
        function from_start(obj)
            fseek(obj.fid, 24, -1);
        end
        
        function frames = all(obj)
            i = 1;
            frames = cell(1);
            obj.from_start();
            while true
                frame = obj.next();

                if isempty(frame)
                    break;
                end
                
                frames{i} = frame;
                i = i + 1;
            end
        end
    end
    
end

