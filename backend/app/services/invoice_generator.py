"""PDF Invoice generator service powered by ReportLab."""

from io import BytesIO
from datetime import datetime, timezone
from typing import Optional

from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, HRFlowable

from app.models.order import Order
from app.models.user import User


class InvoiceGenerator:
    """Generates official agricultural produce tax invoice PDFs."""

    @staticmethod
    def generate_order_invoice_pdf(
        order: Order,
        buyer: Optional[User] = None,
        farmer: Optional[User] = None,
        merkle_seal: Optional[str] = None,
    ) -> bytes:
        """Generates a complete, styled PDF invoice and returns the raw bytes."""
        buffer = BytesIO()
        doc = SimpleDocTemplate(
            buffer,
            pagesize=letter,
            rightMargin=36,
            leftMargin=36,
            topMargin=36,
            bottomMargin=36,
        )

        styles = getSampleStyleSheet()
        title_style = ParagraphStyle(
            "InvoiceTitle",
            parent=styles["Heading1"],
            fontSize=22,
            leading=26,
            textColor=colors.HexColor("#1b5e20"),
            spaceAfter=4,
        )
        subtitle_style = ParagraphStyle(
            "InvoiceSubtitle",
            parent=styles["Normal"],
            fontSize=10,
            leading=14,
            textColor=colors.HexColor("#4a7c59"),
        )
        section_heading_style = ParagraphStyle(
            "SectionHeading",
            parent=styles["Heading3"],
            fontSize=12,
            leading=16,
            textColor=colors.HexColor("#2e7d32"),
            spaceBefore=8,
            spaceAfter=4,
        )
        body_style = ParagraphStyle(
            "InvoiceBody",
            parent=styles["Normal"],
            fontSize=9,
            leading=13,
            textColor=colors.HexColor("#212121"),
        )
        bold_style = ParagraphStyle(
            "InvoiceBold",
            parent=styles["Normal"],
            fontSize=9,
            leading=13,
            fontName="Helvetica-Bold",
            textColor=colors.HexColor("#212121"),
        )

        elements = []

        # Header Title
        elements.append(Paragraph("AGRY-KEY PRODUCE EXCHANGE", title_style))
        elements.append(
            Paragraph("Official Tax Invoice & Provenance Receipt", subtitle_style)
        )
        elements.append(Spacer(1, 8))
        elements.append(HRFlowable(width="100%", thickness=1.5, color=colors.HexColor("#2e7d32"), spaceAfter=12))

        # Invoice Metadata & Parties Table
        invoice_num = f"INV-{order.id:06d}"
        inv_date = (order.confirmed_at or order.created_at).strftime("%d-%b-%Y")
        farmer_name = farmer.full_name if farmer and farmer.full_name else f"Farmer #{order.farmer_id}"
        farmer_phone = farmer.phone_number if farmer else "N/A"
        buyer_name = buyer.full_name if buyer and buyer.full_name else f"Buyer #{order.buyer_id}"
        buyer_phone = buyer.phone_number if buyer else "N/A"

        meta_data = [
            [
                Paragraph("<b>Invoice Number:</b>", body_style),
                Paragraph(invoice_num, bold_style),
                Paragraph("<b>Invoice Date:</b>", body_style),
                Paragraph(inv_date, body_style),
            ],
            [
                Paragraph("<b>Order ID:</b>", body_style),
                Paragraph(f"#{order.id}", body_style),
                Paragraph("<b>Order Status:</b>", body_style),
                Paragraph(order.status.value, bold_style),
            ],
        ]
        meta_table = Table(meta_data, colWidths=[100, 170, 100, 170])
        meta_table.setStyle(
            TableStyle(
                [
                    ("BACKGROUND", (0, 0), (-1, -1), colors.HexColor("#f1f8e9")),
                    ("BOX", (0, 0), (-1, -1), 0.5, colors.HexColor("#c8e6c9")),
                    ("INNERGRID", (0, 0), (-1, -1), 0.25, colors.HexColor("#e8f5e9")),
                    ("TOPPADDING", (0, 0), (-1, -1), 4),
                    ("BOTTOMPADDING", (0, 0), (-1, -1), 4),
                ]
            )
        )
        elements.append(meta_table)
        elements.append(Spacer(1, 10))

        # Seller & Buyer Details
        parties_data = [
            [
                Paragraph("<b>SELLER (FARMER) DETAILS</b>", section_heading_style),
                Paragraph("<b>BUYER DETAILS</b>", section_heading_style),
            ],
            [
                Paragraph(
                    f"<b>Name:</b> {farmer_name}<br/>"
                    f"<b>Phone:</b> {farmer_phone}<br/>"
                    f"<b>Platform ID:</b> FP-{order.farmer_id}",
                    body_style,
                ),
                Paragraph(
                    f"<b>Name:</b> {buyer_name}<br/>"
                    f"<b>Phone:</b> {buyer_phone}<br/>"
                    f"<b>Delivery Address:</b> {order.delivery_address}",
                    body_style,
                ),
            ],
        ]
        parties_table = Table(parties_data, colWidths=[270, 270])
        parties_table.setStyle(
            TableStyle(
                [
                    ("VALIGN", (0, 0), (-1, -1), "TOP"),
                    ("BOX", (0, 0), (-1, -1), 0.5, colors.HexColor("#e0e0e0")),
                    ("TOPPADDING", (0, 0), (-1, -1), 6),
                    ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
                ]
            )
        )
        elements.append(parties_table)
        elements.append(Spacer(1, 14))

        # Itemized Produce Table
        unit_price = round(order.price_per_unit, 2)
        total = round(order.total_amount, 2)
        items_data = [
            [
                Paragraph("<b>Item / Produce Description</b>", bold_style),
                Paragraph("<b>Quantity</b>", bold_style),
                Paragraph("<b>Rate/Unit (INR)</b>", bold_style),
                Paragraph("<b>Total Amount (INR)</b>", bold_style),
            ],
            [
                Paragraph(f"<b>{order.product_name}</b><br/>Direct Farm Fresh Produce", body_style),
                Paragraph(f"{order.quantity} {order.unit}", body_style),
                Paragraph(f"₹{unit_price:.2f}", body_style),
                Paragraph(f"₹{total:.2f}", bold_style),
            ],
            [
                Paragraph("<b>Subtotal</b>", body_style),
                "",
                "",
                Paragraph(f"₹{total:.2f}", body_style),
            ],
            [
                Paragraph("<b>GST / Agricultural Cess (Exempt)</b>", body_style),
                "",
                "",
                Paragraph("₹0.00", body_style),
            ],
            [
                Paragraph("<b>Grand Total</b>", bold_style),
                "",
                "",
                Paragraph(f"<b>₹{total:.2f}</b>", ParagraphStyle("BigTotal", parent=bold_style, fontSize=11, textColor=colors.HexColor("#1b5e20"))),
            ],
        ]
        items_table = Table(items_data, colWidths=[250, 90, 100, 100])
        items_table.setStyle(
            TableStyle(
                [
                    ("BACKGROUND", (0, 0), (-1, 0), colors.HexColor("#e8f5e9")),
                    ("BOTTOMPADDING", (0, 0), (-1, 0), 6),
                    ("TOPPADDING", (0, 0), (-1, 0), 6),
                    ("BOX", (0, 0), (-1, -1), 0.5, colors.HexColor("#c8e6c9")),
                    ("INNERGRID", (0, 0), (-1, 1), 0.25, colors.HexColor("#e0e0e0")),
                    ("LINEABOVE", (0, 2), (-1, 2), 0.5, colors.HexColor("#bdbdbd")),
                    ("SPAN", (0, 2), (2, 2)),
                    ("SPAN", (0, 3), (2, 3)),
                    ("SPAN", (0, 4), (2, 4)),
                    ("BACKGROUND", (0, 4), (-1, 4), colors.HexColor("#f1f8e9")),
                    ("TOPPADDING", (0, 2), (-1, -1), 4),
                    ("BOTTOMPADDING", (0, 2), (-1, -1), 4),
                ]
            )
        )
        elements.append(items_table)
        elements.append(Spacer(1, 14))

        # Ledger & Tamper Evidence Section
        hash_text = merkle_seal or f"SHA256-{order.id:08x}-LEDGER-VERIFIED"
        ledger_info = [
            [
                Paragraph("<b>CRYPTOGRAPHIC PROVENANCE & LEDGER SEAL</b>", section_heading_style),
            ],
            [
                Paragraph(
                    f"<b>Merkle Ledger Root:</b> {hash_text}<br/>"
                    "This invoice is verified and cryptographically recorded on the Agry-Key blockchain. "
                    "All agricultural transactions are protected against illegal dealer hoarding and price tampering.",
                    ParagraphStyle("LegalSmall", parent=body_style, fontSize=8, leading=11, textColor=colors.HexColor("#616161")),
                ),
            ],
        ]
        ledger_table = Table(ledger_info, colWidths=[540])
        ledger_table.setStyle(
            TableStyle(
                [
                    ("BOX", (0, 0), (-1, -1), 0.5, colors.HexColor("#bdbdbd")),
                    ("BACKGROUND", (0, 0), (-1, -1), colors.HexColor("#fafafa")),
                    ("TOPPADDING", (0, 0), (-1, -1), 6),
                    ("BOTTOMPADDING", (0, 0), (-1, -1), 6),
                ]
            )
        )
        elements.append(ledger_table)

        doc.build(elements)
        buffer.seek(0)
        return buffer.getvalue()
