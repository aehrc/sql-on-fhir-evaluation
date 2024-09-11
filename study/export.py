import os


class DataExporter:
    export_views = [
        'subject',
        'reading_o2_flow',
        'reading_spo2',
        'reading_so2'
    ]

    def __init__(self, view_ctx):
        self.view_ctx = view_ctx

    def export(self, output_dir):
        for view_tag in self.export_views:
            print(f"Exporting view: {view_tag}")
            self.view_ctx.get_view(f'coh_{view_tag}').to_csv(os.path.join(output_dir, f"{view_tag}.csv"))
