crop_size = (
    256,
    256,
)
data_preprocessor = dict(
    bgr_to_rgb=True,
    mean=[
        0,
        0,
        0,
    ],
    pad_val=0,
    seg_pad_val=255,
    size=(
        256,
        256,
    ),
    std=[
        1,
        1,
        1,
    ],
    type='SegDataPreProcessor')
data_root = '/content/drive/MyDrive/Lab_EIM/Progetto_finale_EIM/Divisione_dataset5'
dataset_type = 'PolypGen'
default_hooks = dict(
    checkpoint=dict(
        by_epoch=False,
        interval=448,
        max_keep_ckpts=1,
        rule='greater',
        save_best='mDice',
        type='CheckpointHook'),
    early_stopping=dict(
        min_delta=0.01,
        monitor='mIoU',
        patience=10,
        rule='greater',
        type='EarlyStoppingHook'),
    logger=dict(interval=50, log_metric_by_epoch=False, type='LoggerHook'),
    param_scheduler=dict(type='ParamSchedulerHook'),
    sampler_seed=dict(type='DistSamplerSeedHook'),
    timer=dict(type='IterTimerHook'),
    visualization=dict(type='SegVisualizationHook'))
default_scope = 'mmseg'
device = 'cuda'
env_cfg = dict(
    cudnn_benchmark=True,
    dist_cfg=dict(backend='nccl'),
    mp_cfg=dict(mp_start_method='fork', opencv_num_threads=0))
img_ratios = [
    0.8,
    0.95,
    1.0,
    1.05,
    1.15,
]
launcher = 'none'
load_from = '/content/drive/MyDrive/Lab_EIM/Progetto_finale_EIM/Confronto_reti/Training_resnet50_dataset5/Resnet50_dataset5_crop_res_specH2_gamma/results/weights_deeplabV3+/Copia di best_mDice_iter_3584.pth'
log_level = 'INFO'
log_processor = dict(by_epoch=False)
model = dict(
    auxiliary_head=dict(
        align_corners=False,
        channels=256,
        concat_input=False,
        dropout_ratio=0.1,
        in_channels=1024,
        in_index=2,
        loss_decode=dict(
            loss_weight=0.4, type='CrossEntropyLoss', use_sigmoid=False),
        norm_cfg=dict(type='BN'),
        num_classes=2,
        num_convs=1,
        type='FCNHead'),
    backbone=dict(
        contract_dilation=True,
        depth=50,
        dilations=(
            1,
            1,
            2,
            4,
        ),
        norm_cfg=dict(type='BN'),
        norm_eval=False,
        num_stages=4,
        out_indices=(
            0,
            1,
            2,
            3,
        ),
        strides=(
            1,
            2,
            1,
            1,
        ),
        style='pytorch',
        type='ResNetV1c'),
    data_preprocessor=dict(
        bgr_to_rgb=True,
        mean=[
            0,
            0,
            0,
        ],
        pad_val=0,
        seg_pad_val=255,
        size=(
            256,
            256,
        ),
        std=[
            1,
            1,
            1,
        ],
        type='SegDataPreProcessor'),
    decode_head=dict(
        align_corners=False,
        c1_channels=48,
        c1_in_channels=256,
        channels=512,
        dilations=(
            1,
            12,
            24,
            36,
        ),
        dropout_ratio=0.1,
        in_channels=2048,
        in_index=3,
        loss_decode=[
            dict(loss_weight=0.9, type='CrossEntropyLoss', use_sigmoid=False),
            dict(loss_weight=0.1, type='CrossEntropyLoss', use_sigmoid=False),
        ],
        norm_cfg=dict(type='BN'),
        num_classes=2,
        type='DepthwiseSeparableASPPHead'),
    pretrained=None,
    test_cfg=dict(mode='whole'),
    train_cfg=None,
    type='EncoderDecoder')
norm_cfg = dict(type='BN')
optim_wrapper = dict(
    clip_grad=None,
    optimizer=dict(lr=0.001, momentum=0.9, type='SGD', weight_decay=0.0005),
    type='OptimWrapper')
optimizer = dict(lr=0.001, momentum=0.9, type='SGD', weight_decay=0.0005)
param_scheduler = [
    dict(
        begin=0,
        by_epoch=False,
        end=40000,
        eta_min=0.0001,
        power=0.9,
        type='PolyLR'),
]
resume = False
test_cfg = dict(type='TestLoop')
test_dataloader = dict(
    batch_size=1,
    dataset=dict(
        data_prefix=dict(
            img_path=
            '/content/drive/MyDrive/Lab_EIM/Progetto_finale_EIM/Divisione_dataset5/Test/img_crop_res_specH_gamma',
            seg_map_path=
            '/content/drive/MyDrive/Lab_EIM/Progetto_finale_EIM/Divisione_dataset5/Test/mask_crop_res'
        ),
        data_root=
        '/content/drive/MyDrive/Lab_EIM/Progetto_finale_EIM/Divisione_dataset5',
        pipeline=[
            dict(type='LoadImageFromFile'),
            dict(keep_ratio=True, scale=(
                256,
                256,
            ), type='Resize'),
            dict(reduce_zero_label=False, type='LoadAnnotations'),
            dict(type='PackSegInputs'),
        ],
        type='PolypGen'),
    num_workers=4,
    persistent_workers=True,
    sampler=dict(shuffle=False, type='DefaultSampler'))
test_evaluator = dict(
    iou_metrics=[
        'mIoU',
        'mDice',
    ], type='IoUMetric')
test_pipeline = [
    dict(type='LoadImageFromFile'),
    dict(keep_ratio=True, scale=(
        256,
        256,
    ), type='Resize'),
    dict(reduce_zero_label=False, type='LoadAnnotations'),
    dict(type='PackSegInputs'),
]
train_cfg = dict(max_iters=10000, type='IterBasedTrainLoop', val_interval=448)
train_dataloader = dict(
    batch_size=6,
    dataset=dict(
        data_prefix=dict(
            img_path=
            '/content/drive/MyDrive/Lab_EIM/Progetto_finale_EIM/Divisione_dataset5/Training/img_crop_res_specH_gamma',
            seg_map_path=
            '/content/drive/MyDrive/Lab_EIM/Progetto_finale_EIM/Divisione_dataset5/Training/mask_crop_res'
        ),
        data_root=
        '/content/drive/MyDrive/Lab_EIM/Progetto_finale_EIM/Divisione_dataset5',
        pipeline=[
            dict(type='LoadImageFromFile'),
            dict(reduce_zero_label=False, type='LoadAnnotations'),
            dict(
                keep_ratio=True,
                ratio_range=(
                    0.95,
                    1.05,
                ),
                scale=(
                    256,
                    256,
                ),
                type='RandomResize'),
            dict(
                cat_max_ratio=0.95, crop_size=(
                    256,
                    256,
                ), type='RandomCrop'),
            dict(prob=0.5, type='RandomFlip'),
            dict(type='PhotoMetricDistortion'),
            dict(type='PackSegInputs'),
        ],
        type='PolypGen'),
    num_workers=2,
    persistent_workers=True,
    sampler=dict(shuffle=True, type='InfiniteSampler'))
train_pipeline = [
    dict(type='LoadImageFromFile'),
    dict(reduce_zero_label=False, type='LoadAnnotations'),
    dict(
        keep_ratio=True,
        ratio_range=(
            0.95,
            1.05,
        ),
        scale=(
            256,
            256,
        ),
        type='RandomResize'),
    dict(cat_max_ratio=0.95, crop_size=(
        256,
        256,
    ), type='RandomCrop'),
    dict(prob=0.5, type='RandomFlip'),
    dict(type='PhotoMetricDistortion'),
    dict(type='PackSegInputs'),
]
tta_model = dict(type='SegTTAModel')
tta_pipeline = [
    dict(backend_args=None, type='LoadImageFromFile'),
    dict(
        transforms=[
            [
                dict(keep_ratio=True, scale_factor=0.5, type='Resize'),
                dict(keep_ratio=True, scale_factor=0.75, type='Resize'),
                dict(keep_ratio=True, scale_factor=1.0, type='Resize'),
                dict(keep_ratio=True, scale_factor=1.25, type='Resize'),
                dict(keep_ratio=True, scale_factor=1.5, type='Resize'),
                dict(keep_ratio=True, scale_factor=1.75, type='Resize'),
            ],
            [
                dict(direction='horizontal', prob=0.0, type='RandomFlip'),
                dict(direction='horizontal', prob=1.0, type='RandomFlip'),
            ],
            [
                dict(type='LoadAnnotations'),
            ],
            [
                dict(type='PackSegInputs'),
            ],
        ],
        type='TestTimeAug'),
]
val_cfg = dict(type='ValLoop')
val_dataloader = dict(
    batch_size=6,
    dataset=dict(
        data_prefix=dict(
            img_path=
            '/content/drive/MyDrive/Lab_EIM/Progetto_finale_EIM/Divisione_dataset5/Validation/img_crop_res_specH_gamma',
            seg_map_path=
            '/content/drive/MyDrive/Lab_EIM/Progetto_finale_EIM/Divisione_dataset5/Validation/mask_crop_res'
        ),
        data_root=
        '/content/drive/MyDrive/Lab_EIM/Progetto_finale_EIM/Divisione_dataset5',
        pipeline=[
            dict(type='LoadImageFromFile'),
            dict(keep_ratio=True, scale=(
                256,
                256,
            ), type='Resize'),
            dict(reduce_zero_label=False, type='LoadAnnotations'),
            dict(type='PackSegInputs'),
        ],
        type='PolypGen'),
    num_workers=4,
    persistent_workers=True,
    sampler=dict(shuffle=False, type='DefaultSampler'))
val_evaluator = dict(
    iou_metrics=[
        'mIoU',
        'mDice',
    ], type='IoUMetric')
vis_backends = [
    dict(type='LocalVisBackend'),
]
visualizer = dict(
    classes=(
        'background',
        'object',
    ),
    name='visualizer',
    palette=[
        (
            0,
            0,
            0,
        ),
        (
            255,
            255,
            255,
        ),
    ],
    save_dir=
    '/content/drive/MyDrive/Lab_EIM/Progetto_finale_EIM/Confronto_reti/Training_resnet50_dataset5/Resnet50_dataset5_crop_res_specH2_gamma/results/weights_deeplabV3+',
    type='SegLocalVisualizer',
    vis_backends=[
        dict(type='LocalVisBackend'),
    ])
work_dir = '/content/drive/MyDrive/Lab_EIM/Progetto_finale_EIM/Confronto_reti/Training_resnet50_dataset5/Resnet50_dataset5_crop_res_specH2_gamma/results/weights_deeplabV3+'
workflow = [
    (
        'train',
        1,
    ),
    (
        'val',
        1,
    ),
]
