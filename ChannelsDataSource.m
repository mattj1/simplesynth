#import "ChannelsDataSource.h"


@implementation ChannelsDataSource


- (id)initWithAudioSystem:(AudioSystem*)newAudioSystem
{
    audioSystem = newAudioSystem;
    
    return self;
}


- (int)numberOfRowsInTableView:(NSTableView*)tableView
{
    return 16;
}


- (id)tableView:(NSTableView*)tableView objectValueForTableColumn:(NSTableColumn*)column row:(int)rowIndex
{
    if ([[column identifier] isEqualToString:@"channel"]) {
        return [NSString stringWithFormat:@"%d", rowIndex+1];
    }
    else {
        return [audioSystem nameOfInstrument:[audioSystem currentInstrumentOnChannel:rowIndex]];
    }
}


@end
