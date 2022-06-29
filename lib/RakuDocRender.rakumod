use v6.d;

use Pod::To::HTML2:auth<zef:finanalyst>;
use Pod::To::MarkDown2:auth<zef:finanalyst>;
use ExtractPod;

use GTK::Simple::App;
use GTK::Simple::FileChooserButton;
use GTK::Simple::MarkUpLabel;
use GTK::Simple::VBox;
use GTK::Simple::HBox;
use GTK::Simple::CheckButton;
use GTK::Simple::Entry;
use GTK::Simple::Button;
use GTK::Simple::TextView;
use GTK::Simple::Grid;

unit module RakuDocRender;

#| adds a line to the grid. Needs @files to fix the line
sub add-line(GTK::Simple::Grid $grid, @files) {
    my $grid-line = @files.elems + 1;
    my $col = 0;
    my %cnf = %(
        :path(''), :file(''), :oname(''),
        :convert, :md, :md-badge, :html, :html-hl
    );
    $grid.attach(
        [$col++, $grid-line, 1, 1] => my $path = GTK::Simple::MarkUpLabel.new(:label('')),
        [$col++, $grid-line, 1, 1] => my $fc = GTK::Simple::FileChooserButton.new(:label('New file')),
        [$col++, $grid-line, 1, 1] => my $convert = GTK::Simple::CheckButton.new(:label('')),
        [$col++, $grid-line, 1, 1] => my $oname = GTK::Simple::Entry.new(text => %cnf<oname>),
        [$col++, $grid-line, 1, 1] => my $md = GTK::Simple::CheckButton.new(:label('')),
        [$col++, $grid-line, 1, 1] => my $md-badge = GTK::Simple::CheckButton.new(:label('')),
        [$col++, $grid-line, 1, 1] => my $html = GTK::Simple::CheckButton.new(:label('')),
        [$col++, $grid-line, 1, 1] => my $html-hl = GTK::Simple::CheckButton.new(:label('')),
        );
    $md.status = $convert.status =
        $md.sensitive = $md-badge.sensitive = $html.sensitive = $convert.sensitive
            = False;
    # == Defined click actions for each file ===================================
    $md.toggled.tap: -> $b {
        %cnf<md> = !%cnf<md>;
        $md-badge.sensitive = %cnf<md>;
        $md-badge.status = False unless %cnf<md>;
    }
    $md-badge.toggled.tap: -> $b {
        %cnf<md-badge> = !%cnf<md-badge>;
    }
    $html.toggled.tap: -> $b {
        %cnf<html> = !%cnf<html>;
        $html-hl.sensitive = %cnf<html>;
        $html-hl.status = False unless %cnf<html>;
    }
    $html-hl.toggled.tap: -> $b {
        %cnf<html-hl> = !%cnf<html-hl>;
    }
    $convert.toggled.tap: -> $b {
        %cnf<convert> = !%cnf<convert>
    }

    $oname.changed.tap: -> $b { %cnf<oname> = $oname.text }
    # All option buttons off until a file is chosen
    $md.sensitive = $md-badge.sensitive =
        $html.sensitive = $html-hl.sensitive =
            $convert.sensitive = $oname.sensitive =
                $convert.status = $md.status = $md-badge.status =
                    $html.status = $html-hl.status =
                        False;
    %cnf{$_} = False for <md html md-badge html-hl convert>;
    $fc.file-set.tap: {
        my Bool $add = not %cnf<path>;
        my $fn = $fc.file-name;
        %cnf<file> = $fn;
        %cnf<path> = $fn.IO.relative.IO.dirname;
        $path.text = '<span foreground="darkgreen">' ~ %cnf<path> ~ '/</span>';
        %cnf<oname> = $fn.IO.basename.IO.extension('').Str;
        $oname.text = %cnf<oname>;
        $md.sensitive = $html.sensitive = $convert.sensitive = $oname.sensitive = True;
        if $add {
            add-line($grid, @files)
        }
        else {
            # new file chosen, so reset status / options
            $convert.status = $md.status = $md-badge.status =
                $html.status = $html-hl.status =
                    False;
            %cnf{$_} = False for <md html md-badge html-hl convert>
        }
    }
    @files.push: %cnf
}
sub MAIN is export {
    my @files;
    # App initiation ============================
    my $app = GTK::Simple::App.new(:title("Rakudoc Extractor Utility"));
    $app.border-width = 5;
    # ===============================================================
    # File box
    my $col = 0;
    my $file-grid = GTK::Simple::Grid.new(
        [$col++, 0, 1, 1] => GTK::Simple::MarkUpLabel.new(:text('<span foreground="darkgreen">input file path</span>')),
        [$col++, 0, 1, 1] => GTK::Simple::MarkUpLabel.new(:text('{' ~ '-' x 12 ~ '<span foreground="green">input file</span>' ~ '-' x 12 ~ '}')),
        [$col++, 0, 1, 1] => GTK::Simple::MarkUpLabel.new(:text('<span foreground="blue">Convert?</span>')),
        [$col++, 0, 1, 1] => GTK::Simple::MarkUpLabel.new(:text('<span foreground="green">output file in CWD</span>')),
        [$col++, 0, 1, 1] => GTK::Simple::MarkUpLabel.new(:text('<span foreground="blue">.md?</span>')),
        [$col++, 0, 1, 1] => GTK::Simple::MarkUpLabel.new(:text('<span foreground="violet">badge?</span>')),
        [$col++, 0, 1, 1] => GTK::Simple::MarkUpLabel.new(:text('<span foreground="blue">.html?</span>')),
        [$col++, 0, 1, 1] => GTK::Simple::MarkUpLabel.new(:text('<span foreground="violet">hilite?</span>')),
        );
    $file-grid.column-spacing = 10;
    add-line($file-grid, @files);
    # Report pane ===============================================================
    my $report = GTK::Simple::TextView.new;
    $report.alignment = LEFT;
    # =Bottom buttons ============================================
    my $cancel;
    my $action;
    my $button-row = GTK::Simple::HBox.new([
        $cancel = GTK::Simple::Button.new(:label<Cancel>),
        $action = GTK::Simple::Button.new(:label<Convert>)
    ]);
    $cancel.clicked.tap: -> $b { $app.exit };
    $action.clicked.tap: -> $b {
        if +@files > 1 {
            $cancel.label = 'Finish';
            my @md = @files.grep({ .<file> and .<md> and .<convert> });
            my @html = @files.grep({ .<file> and .<html> and .<convert> });
            HTML(@html, $report) if ?@html;
            MarkDown(@md, $report) if ?@md;
            unless ?@html or ?@md {
                $report.text ~= "No files with .md or .html selected\n"
            }
        }
        else {
            $report.text ~= "Select a file and add conversion option\n"
        }
    };
    #=============================
    # App setup and run
    $app.set-content(GTK::Simple::VBox.new([
        { :widget($file-grid), :!expand },
        { :widget($button-row), :!expand },
        { :widget($report), :!expand }
    ]));
    $app.show;
    $app.run
}
sub HTML(@fn, $report) {
    # when there is no highlighting, the code needs escaping
    my Pod::To::HTML2 $pr .= new;
    process(@fn, $report, $pr, 'html')
}

sub MarkDown(@fn, $report) {
    my Pod::To::MarkDown2 $pr .= new;
    process(@fn, $report, $pr, 'md')
}

sub process(@fn, $report, $pr, $ext) {
    for @fn -> $fn {
        $pr.pod-file.path = $pr.pod-file.name = $pr.pod-file.title = $fn<oname>;
        $pr.github-badge = $fn<md-badge> if $fn<md>;
        $pr.highlight = $fn<html-hl> if $fn<html>;
        my $pod = load($fn<path> ~ '/' ~ $fn<name>);
        $pr.render-tree($pod);
        $pr.file-wrap;
        $pr.emit-and-renew-processed-state;
        $report.text ~= "｢{ $fn<path> }/{ $fn<name> }｣"
            ~ " converted and written to ｢{ $fn<oname> }.$ext｣\n";
        CATCH {
            default {
                exit note( .message ~ .backtrace);
#                my $msg = .message;
#                $msg = $msg.substr(0, 150) ~ "\n{ '... (' ~ $msg.chars - 150 ~ ' more chars)' if $msg.chars > 150 }";
#                $report.text ~= "｢{ $fn<path> }/{ $fn<name> }｣"
#                    ~ " to .$ext "
#                    ~ ' encountered error: '
#                    ~ .message ~ "\n";
#                .resume
            }
        }
    }
}

