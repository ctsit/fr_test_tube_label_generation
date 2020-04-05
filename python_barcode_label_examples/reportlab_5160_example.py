from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter
from reportlab.lib.units import inch
import os, glob, sys, time
import textwrap

#Logic for averyLabel 5160
def avery5160(outfile, font, font_size, addressInput):
    print 'Creating labels in Avery 5160 format'
    # PDF vars
    if os.path.exists(outfile):
        os.remove(outfile)
    out_pdf = canvas.Canvas(outfile, pagesize = letter)
    out_pdf.setFont(font, font_size)
    addressItem = addressInput.split('$')
    hs = 0.25
    vs = 10.3
    horizontal_start = hs * inch #staring point of label horizontally
    vertical_start = vs * inch #starting point of label vertically
    count = 0           #initially the count is 0

    for item in addressItem:

        if count > 0 and count % 30 == 0:
            out_pdf.showPage()
            out_pdf.setFont(font, font_size)
            horizontal_start = hs * inch
            vertical_start = vs * inch
        elif count > 0 and count % 10 == 0:
            horizontal_start = horizontal_start + 2.8 *inch
            vertical_start = vs * inch

        label = out_pdf.beginText()
        label.setTextOrigin(horizontal_start, vertical_start)

        details = item.split('~')

        for detail in details:
            if len(detail) > 45:
                name = detail[0:44]
                label.textLine(name)
                name = detail[44:60]
                label.textLine(name)
            else:
                label.textLine(detail)

        out_pdf.drawText(label)

        vertical_start = vertical_start - 1.05 * inch
        count = count + 1

    out_pdf.showPage()
    out_pdf.save()
    print '\nCreated %s\n' %outfile  
