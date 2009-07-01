/*
 * AQGlassButton.m
 * AQGlassButton
 * 
 * Created by Jim Dovey on 3/6/2009.
 * 
 * Copyright (c) 2009 Jim Dovey
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 
 * Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 * 
 * Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in the
 * documentation and/or other materials provided with the distribution.
 * 
 * Neither the name of the project's author nor the names of its
 * contributors may be used to endorse or promote products derived from
 * this software without specific prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 * FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 * TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

#import "AQGlassButton.h"

@implementation AQGlassButton

@synthesize tintColor=_tintColor;

- (void) updatePath
{
    CGRect bounds = self.bounds;
    
    if ( _path != NULL )
    {
        CGPathRelease( _path );
        _path = NULL;
    }
    
    CGFloat cornerRadius = floorf( bounds.size.height * 0.2 );
    
    _path = CGPathCreateMutable();
    CGPathMoveToPoint( _path, NULL, CGRectGetMinX(bounds), CGRectGetMinY(bounds) + cornerRadius );
    CGPathAddLineToPoint( _path, NULL, CGRectGetMinX(bounds), CGRectGetMaxY(bounds) - cornerRadius );
    CGPathAddArcToPoint( _path, NULL, CGRectGetMinX(bounds), CGRectGetMaxY(bounds),
                         CGRectGetMinX(bounds) + cornerRadius, CGRectGetMaxY(bounds), cornerRadius );
    CGPathAddLineToPoint( _path, NULL, CGRectGetMaxX(bounds) - cornerRadius, CGRectGetMaxY(bounds) );
    CGPathAddArcToPoint( _path, NULL, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), 
                         CGRectGetMaxX(bounds), CGRectGetMaxY(bounds) - cornerRadius, cornerRadius );
    CGPathAddLineToPoint( _path, NULL, CGRectGetMaxX(bounds), CGRectGetMinY(bounds) + cornerRadius );
    CGPathAddArcToPoint( _path, NULL, CGRectGetMaxX(bounds), CGRectGetMinY(bounds),
                         CGRectGetMaxX(bounds) - cornerRadius, CGRectGetMinY(bounds), cornerRadius );
    CGPathAddLineToPoint( _path, NULL, CGRectGetMinX(bounds) + cornerRadius, CGRectGetMinY(bounds) );
    CGPathAddArcToPoint( _path, NULL, CGRectGetMinX(bounds), CGRectGetMinY(bounds),
                         CGRectGetMinX(bounds), CGRectGetMinY(bounds) + cornerRadius, cornerRadius );
    CGPathCloseSubpath( _path );
}

- (void) setup
{
    if ( _gradient != NULL )
        CGGradientRelease( _gradient );
    
    CGColorRef color = self.tintColor.CGColor;
    CGColorSpaceRef space = CGColorGetColorSpace( color );
    
    size_t numComponents = CGColorGetNumberOfComponents( color );
    const CGFloat * srcComponents = CGColorGetComponents( color );
    CGFloat tintAlpha = CGColorGetAlpha( color );
    
    CGFloat * components = (CGFloat *) NSZoneMalloc( [self zone], numComponents * 5 * sizeof(CGFloat) );
    
    int i, j;
    CGFloat alphas[5] = {
        0.60 * tintAlpha,
        0.40 * tintAlpha,
        0.20 * tintAlpha,
        0.23 * tintAlpha,
        0.30 * tintAlpha
    };
    for ( i = 0; i < 5; i++ )
    {
        for ( j = 0; j < numComponents-1; j++ )
            components[i*numComponents+j] = srcComponents[j];
        components[i*numComponents+j] = alphas[i];
    }
    /*
     for the default (grey) tint color, we'll ultimately have this:
    CGFloat components[20] = {
        0.6, 0.6, 0.6, 0.6,
        0.6, 0.6, 0.6, 0.4,
        0.6, 0.6, 0.6, 0.2,
        0.6, 0.6, 0.6, 0.23,
        0.6, 0.6, 0.6, 0.3
    };
    */
    CGFloat locations[5] = {
        1.0, 0.5, 0.499, 0.1, 0.0
    };
    
    _gradient = CGGradientCreateWithColorComponents( space, components, locations, 5 );
    NSZoneFree( [self zone], components );
    
    if ( !CGRectIsEmpty(self.bounds) )
        [self updatePath];
}

- (id) initWithFrame: (CGRect) frameRect
{
    self = [super initWithFrame: frameRect];
    if ( self == nil )
        return ( nil );
    
    _tintColor = [[UIColor alloc] initWithRed: 0.6 green: 0.6 blue: 0.6 alpha: 1.0];
    [self setup];
    
    return ( self );
}

- (id) initWithCoder: (NSCoder *) coder
{
    self = [super initWithCoder: coder];
    if ( self == nil )
        return ( nil );
    
    _tintColor = [[coder decodeObjectForKey: @"tintColor"] retain];
    if ( self.tintColor == nil )
        _tintColor = [[UIColor alloc] initWithRed: 0.6 green: 0.6 blue: 0.6 alpha: 1.0];
    
    [self setup];
    
    return ( self );
}

- (void) dealloc
{
    CGPathRelease( _path );
    CGGradientRelease( _gradient );
    [_tintColor release];
    [super dealloc];
}

- (void) encodeWithCoder: (NSCoder *) coder
{
    [super encodeWithCoder: coder];
    [coder encodeObject: self.tintColor forKey: @"tintColor"];
}

- (void) setHighlighted: (BOOL) highlighted
{
    BOOL old = self.highlighted;
    [super setHighlighted: highlighted];
    
    if ( old != highlighted )
        [self setNeedsDisplay];
}

- (void) setFrame: (CGRect) frame
{
    [super setFrame: frame];
    [self updatePath];
}

- (void) setTintColor: (UIColor *) newColor
{
    [newColor retain];
    [_tintColor release];
    _tintColor = newColor;
    
    // recreate the gradient as appropriate
    [self setup];
}

- (void) drawRect: (CGRect) theRect
{
    [[UIColor darkGrayColor] setStroke];
    
    [[UIColor clearColor] setFill];
    UIRectFill( theRect );
    
    if ( self.highlighted )
        [[UIColor colorWithWhite: 1.0 alpha: 0.1] setFill];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth( ctx, 1.0 );
    CGContextBeginPath( ctx );
    CGContextAddPath( ctx, _path );
    CGContextDrawPath( ctx, kCGPathFillStroke );
    
    CGContextBeginPath( ctx );
    CGContextAddPath( ctx, _path );
    CGContextClip( ctx );
    
    CGRect bounds = self.bounds;
    CGContextDrawLinearGradient( ctx, _gradient, CGPointMake(bounds.origin.x, CGRectGetMaxY(bounds)), bounds.origin, 0 );
}

@end
