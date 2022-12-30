#import <Foundation/Foundation.h>
#import "ATLApplicationSubtitleCell.h"

#import "ATLApplicationListControllerBase.h"

@implementation ATLApplicationSubtitleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier specifier:(PSSpecifier*)specifier
{
	self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];

	if(self)
	{
		_customValueLabel = [UILabel new];
		_customValueLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];

		BOOL isRTL = [UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;
		if(isRTL)
		{
			_customValueLabel.textAlignment = NSTextAlignmentLeft;
		}
		else
		{
			_customValueLabel.textAlignment = NSTextAlignmentRight;
		}

		_customValueLabel.numberOfLines = 1;

		if(@available(iOS 13, *))
		{
			_customValueLabel.textColor = [UIColor secondaryLabelColor];
		}
		else
		{
			_customValueLabel.textColor = [UIColor colorWithRed:0.5568 green:0.5568 blue:0.5764 alpha:1.0];
		}

		[self.contentView addSubview:_customValueLabel];
		_customValueLabel.hidden = YES;
	}

	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];

	BOOL isRTL = [UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft;

	if(isRTL)
	{
		CGFloat detailTextLeftPos = self.detailTextLabel.frame.origin.x;
		CGFloat textLeftPos = self.textLabel.frame.origin.x;
		CGFloat width = 0;
		if(detailTextLeftPos < textLeftPos)
		{
			width = detailTextLeftPos;
		}
		else
		{
			width = textLeftPos;
		}

		_customValueLabel.frame = CGRectMake(0, 0, width, self.contentView.bounds.size.height);
	}
	else
	{
		CGFloat detailTextRightPos = self.detailTextLabel.frame.origin.x + self.detailTextLabel.bounds.size.width;
		CGFloat textRightPos = self.textLabel.frame.origin.x + self.textLabel.bounds.size.width;
		CGFloat x = 0;
		if(detailTextRightPos > textRightPos)
		{
			x = detailTextRightPos;
		}
		else
		{
			x = textRightPos;
		}
		CGFloat width = self.contentView.bounds.size.width - x;
		_customValueLabel.frame = CGRectMake(x, 0, width, self.contentView.bounds.size.height);
	}
}

- (void)refreshCellContentsWithSpecifier:(PSSpecifier*)specifier
{
	[super refreshCellContentsWithSpecifier:specifier];
	id target = specifier.target;
	if([target respondsToSelector:@selector(_subtitleForSpecifier:)])
	{
		self.detailTextLabel.text = [(ATLApplicationListControllerBase*)target _subtitleForSpecifier:specifier];
	}
}

- (void)setValue:(id)value
{
	if([value isKindOfClass:[NSString class]])
	{
		NSString* valueStr = value;
		if(![valueStr isEqualToString:@""])
		{
			_customValueLabel.hidden = NO;
			_customValueLabel.text = valueStr;
			return;
		}
	}

	_customValueLabel.hidden = YES;
}

- (void)prepareForReuse
{
	[super prepareForReuse];
	_customValueLabel.text = nil;
}

@end