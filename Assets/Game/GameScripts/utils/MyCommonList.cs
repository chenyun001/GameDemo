using System;
using System.Collections;
using System.Collections.Generic;
using DG.Tweening;
using UnityEngine;
using UnityEngine.Serialization;
using UnityEngine.UI;
using XLua;



public class MyCommonList : MonoBehaviour
{
	[CSharpCallLua]
	public delegate void UpdateChildrenCallbackDelegate(int index, int trans);

	[CSharpCallLua]
	public delegate void UpdateChildrenInitAnimateDelegate(int index, int trans);

	[SerializeField] protected int _cellHeight;

	[SerializeField] protected int _cellSpaceX;

	[SerializeField] protected int _cellSpaceY;

	[SerializeField] protected int _cellWidth;

	[SerializeField] protected int _constraintCont;
	[SerializeField] private float top = 0f;


	public int ConstraintCont => _constraintCont;

	private Vector2 _defaultPosition;

	[SerializeField] protected bool _horizontal;

	private bool _init;
	private float _lastPosition;

	public float SliderValue = 0;

	private float _sliderLength = 1;
	protected Transform[]   _list;

	//填写每行个数的倍数
	[SerializeField] private int _minAmount;
	private List<int> _nowIndex;

	private int _nowMaxAmount;
	private int _nowMaxIndex;

	private int _nowMinIndex;


	private int _nowRowCount;

	[SerializeField] protected RectTransform _rect;

	[SerializeField] private int _showAmount;

	public int ShowAmount => _showAmount;

	[SerializeField] private AutoSizeType _autoSizeType;
	private int _temp;
	public GameObject ItemCell;

	[SerializeField] public ScrollRect scrollRect;

	public Vector2 scrollSize;

	public UpdateChildrenCallbackDelegate UpdateChildrenCallback;
	public UpdateChildrenInitAnimateDelegate UpdateChildrenAnimate;

	public Action<int> ChangeTargetIndex;

	protected float _spX;
	protected float _spY;

	[SerializeField] private bool moveByStep = false;

	public Transform[] CellList => _list;


	public void Init()
	{
		if (_init) return;

		scrollSize = scrollRect.GetComponent<RectTransform>().rect.size;
		//if (moveByStep) scrollRect.OnEndDragAsObservable().Subscribe(_ => OnEndDrag()).AddTo(this);
		//else
		//{
			
		//}
		scrollRect.onValueChanged.AddListener(ScrollCallback);
		int minSpace = _cellSpaceX;
		_spX = _cellSpaceX;
		_spY = _cellSpaceY;
		switch (_autoSizeType)
		{
			case AutoSizeType.OnlySpace:
				_spX = (_rect.rect.width - _constraintCont * _cellWidth) / (_constraintCont + 1);
				break;
			case AutoSizeType.OnlyCount:
				_constraintCont = Mathf.FloorToInt((_rect.rect.width - _spX) / (_cellWidth + _spX));
				break;
			case AutoSizeType.Both:
				_constraintCont = Mathf.FloorToInt((_rect.rect.width - _spX) / (_cellWidth + _spX));
				_spX = (_rect.rect.width - _constraintCont * _cellWidth) / (_constraintCont + 1);
				if (_spX < minSpace)
				{
					_constraintCont--;
					_spX = (_rect.rect.width - _constraintCont * _cellWidth) / (_constraintCont + 1);
				}
				break;
		}

		_list = new Transform[_minAmount];
		_nowIndex = new List<int>();
		for (var i = 0; i < _minAmount; i++)
		{
			_list[i] = (Instantiate(ItemCell, transform).transform);
			_nowIndex.Add(i);
		}


		_init = true;
	}

	private int _nowStep = 0;

	private void OnEndDrag()
	{
		if (_horizontal)
		{
			if (scrollRect.velocity.x > 5)
			{
				scrollRect.StopMovement();

				MoveToPrevious();
			}
			else if (scrollRect.velocity.x < -5)
			{
				scrollRect.StopMovement();
				MoveToNext();
			}
		}
	}

	public virtual void ScrollCallback(Vector2 data)
	{
		if (!_init) return;

		if (_horizontal)
		{
			if (_rect.anchoredPosition.x < _lastPosition)
			{
				_temp = Mathf.FloorToInt((-_rect.anchoredPosition.x + _spX) /
				                         (_cellWidth + _spX));
				if (_temp > _nowRowCount)
				{
					_temp = _temp - _nowRowCount;
					_nowMinIndex += _constraintCont * _temp;
					_nowMaxIndex += _constraintCont * _temp;
					_nowRowCount =
						Mathf.FloorToInt((-_rect.anchoredPosition.x + _spX) /
						                 (_cellWidth + _spX));
					for (var i = 0; i < _nowIndex.Count; i++)
						if (_nowIndex[i] < _nowMinIndex)
						{
							_nowIndex[i] += _minAmount;
							SetCellPosition(i, _nowIndex[i]);
						}
				}
			}
			else if (_rect.anchoredPosition.x >= _lastPosition)
			{
				_temp = Mathf.FloorToInt(-_rect.anchoredPosition.x /
				                         (_cellWidth + _spX));


				if (_temp < _nowRowCount)
				{
					_temp = _nowRowCount - _temp;
					_nowMinIndex -= _constraintCont * _temp;
					_nowMaxIndex -= _constraintCont * _temp;
					_nowRowCount =
						Mathf.FloorToInt(-_rect.anchoredPosition.x /
						                 (_cellWidth + _spX));
					for (var i = 0; i < _nowIndex.Count; i++)
						if (_nowIndex[i] > _nowMaxIndex)
						{
							_nowIndex[i] -= _minAmount;
							SetCellPosition(i, _nowIndex[i]);
						}
				}
			}

			_lastPosition = _rect.localPosition.x;
		}
		else
		{
			if (_rect.anchoredPosition.y > _lastPosition)
			{
				_temp = Mathf.FloorToInt((_rect.anchoredPosition.y + _spY) /
				                         (_cellHeight + _spY));
				if (_temp > _nowRowCount)
				{
					_temp = _temp - _nowRowCount;
					_nowMinIndex += _constraintCont * _temp;
					_nowMaxIndex += _constraintCont * _temp;
					_nowRowCount =
						Mathf.FloorToInt((_rect.anchoredPosition.y + _spY) /
						                 (_cellHeight + _spY));
					for (var i = 0; i < _nowIndex.Count; i++)
						if (_nowIndex[i] < _nowMinIndex)
						{
							_nowIndex[i] += _minAmount;
							SetCellPosition(i, _nowIndex[i]);
						}
				}
			}
			else if (_rect.anchoredPosition.y <= _lastPosition)
			{
				_temp = Mathf.FloorToInt(_rect.anchoredPosition.y /
				                         (_cellHeight + _spY));
				if (_temp < _nowRowCount)
				{
					_temp = _nowRowCount - _temp;
					_nowMinIndex -= _constraintCont * _temp;
					_nowMaxIndex -= _constraintCont * _temp;
					_nowRowCount =
						Mathf.FloorToInt(_rect.anchoredPosition.y /
						                 (_cellHeight + _spY));
					for (var i = 0; i < _nowIndex.Count; i++)
						if (_nowIndex[i] > _nowMaxIndex)
						{
							_nowIndex[i] -= _minAmount;
							SetCellPosition(i, _nowIndex[i]);
						}
				}
			}

			_lastPosition = _rect.anchoredPosition.y;
			SliderValue = _lastPosition / _sliderLength;
		}
	}

	protected virtual void SetCellPosition(int cellIndex, int i)
	{
		if (cellIndex < 0) return;
		var cell = _list[cellIndex];
		cell.name = i.ToString();
		if (_horizontal)
			cell.localPosition = new Vector3(
				i / _constraintCont * (_cellWidth + _spX) + _spX,
				-i % _constraintCont * (_cellHeight + _spY) - _spY, 0);
		else
			cell.localPosition =
				new Vector3(_spX + i % _constraintCont * (_cellWidth + _spX),
					-i / _constraintCont * (_cellHeight + _spY) - _spY - top);
		if (i >= 0 && UpdateChildrenCallback != null)
			UpdateChildrenCallback.Invoke(i, cellIndex);
		if (i >= _nowMaxAmount || i < 0)
			cell.gameObject.SetActive(false);
		else if (i >= 0)
			cell.gameObject.SetActive(true);
	}

	private void UpdateCellAnimate(int cellIndex, int i)
	{
		if (UpdateChildrenAnimate != null && i > -1)
		{
			UpdateChildrenAnimate.Invoke(i, cellIndex);
		}
	}

	public void FreshState()
	{
		if (_init == false) return;

		for (var i = 0; i < _list.Length; i++)
		{
			if (_list[i].gameObject.activeSelf)
			{
				int index = int.Parse(_list[i].name);
				if (index >= 0)
					UpdateChildrenCallback(index, i);
			}
		}
	}

	//横向单排使用
	public void DoShowInteger(int minSpace)
	{
		Init();
		int showCount = Mathf.FloorToInt((scrollSize.x - minSpace) / (_cellWidth + minSpace));
		_spX = (scrollSize.x - showCount * _cellWidth) / (showCount + 1);
		if (_spX < minSpace)
		{
			showCount--;
			_spX = (scrollSize.x - showCount * _cellWidth) / (showCount + 1);
		}
	}

	private void DoChangeSpace(int minSpace)
	{
		int showCount = Mathf.FloorToInt((scrollSize.x - minSpace) / (_cellWidth + minSpace));
		_spX = (scrollSize.x - showCount * _cellWidth) / (showCount + 1);
		if (_spX < minSpace)
		{
			showCount--;
			_spX = (scrollSize.x - showCount * _cellWidth) / (showCount + 1);
		}
	}
	[LuaCallCSharp]
	public void MoveToIndex(int index)
	{
		index = index / _constraintCont;
		if (_horizontal)
		{
			_rect.DOLocalMove(new Vector3((_cellWidth + _spX) * -index, _defaultPosition.y, 0), 0.3f);
		}
		else
		{
			_rect.DOLocalMove(new Vector3(_defaultPosition.x, (_cellHeight + _spY) * index, 0), 0.3f);
		}

		ChangeTargetIndex?.Invoke(index);
	}

	/// <summary>
	///     移动到item并返回itemTransform
	/// </summary>
	/// <param name="index">移动并选择的item</param>
	/// <param name="cb"></param>
	public void MoveToIndex(int index, Action<Transform> cb)
	{
		index = index / _constraintCont;
		if (_horizontal)
		{
			_rect.DOLocalMove(new Vector3((_cellWidth + _spX) * -index, 0, 0), 0.5f);
		}
		else
		{
			_rect.DOLocalMove(new Vector3(0, (_cellHeight + _spY) * index, 0), 0.5f);
		}
	}

	public void SetCellPositionZero()
	{
		StartCoroutine(StartPositionZeroCo());
	}

	/// <summary>
	/// 重新打开界面时 content位置置顶
	/// </summary>
	/// <returns></returns>
	IEnumerator StartPositionZeroCo()
	{
		yield return new WaitForSeconds(0.2f);
		scrollRect.content.anchoredPosition = Vector2.zero;
		scrollRect.StopMovement();
	}

	public virtual void SetAmount(int amount)
	{
		Init();

		float width;
		float height;
		_nowMaxAmount = amount;
		if (_horizontal)
		{
			width = Mathf.Floor((float) amount / _constraintCont) * (_cellWidth + _spX) + _spX;
			height = _constraintCont * (_cellHeight + _spY);
			if (amount % _constraintCont != 0) width += _cellWidth + _spX;
			if (width < scrollSize.x)
			{
				width = scrollSize.x;
				scrollRect.enabled = false;
			}
			else scrollRect.enabled = true;

			_sliderLength = width - scrollSize.x;
		}
		else
		{
			width = _constraintCont * (_cellWidth + _spX);

			height = Mathf.Floor((float) amount / _constraintCont) * (_cellHeight + _spY);
			if (amount % _constraintCont != 0) height += _cellHeight + _spY;
			if (height < scrollSize.y)
			{
				height = scrollSize.y;
				scrollRect.enabled = false;
			}
			else
			{
				scrollRect.enabled = true;
			}

			_sliderLength = height - scrollSize.y;
		}

		_rect.sizeDelta = new Vector2(width, height + top);
		_rect.anchoredPosition = _defaultPosition;
		_nowRowCount = 0;
		_lastPosition = 0;
		_nowMinIndex = 0;
		_nowMaxIndex = _list.Length - 1;
		for (var i = 0; i < _list.Length; i++)
		{
			if (i >= amount || i < 0)
			{
				_list[i].gameObject.SetActive(false);
			}
			else
			{
				SetCellPosition(i, i);
				UpdateCellAnimate(i, i);
				_list[i].gameObject.SetActive(true);
			}

			_nowIndex[i] = i;
		}
	}

	public void AddAmount(bool moveToIndex = false)
	{
		var index = _nowMaxAmount;
		_nowMaxAmount = _nowMaxAmount + 1;


		if (_nowMaxAmount >= _showAmount)
		{
			scrollRect.enabled = true;
			var sizeDelta = _rect.sizeDelta;
			sizeDelta = new Vector2(sizeDelta.x, (_cellHeight + _cellSpaceY) * _nowMaxAmount);
			_rect.sizeDelta = sizeDelta;

			if (moveToIndex)
			{
				MoveToIndex(index);
			}
		}

		SetCellPosition(GetCellIndex(index), index);
	}

	public void MoveToNext()
	{
		if (_horizontal)
			MoveToIndex(Mathf.FloorToInt(-_lastPosition / (_cellWidth + _spX) * _constraintCont + 1));
	}

	public void MoveToPrevious()
	{
		if (_horizontal)
			MoveToIndex(Mathf.FloorToInt(-_lastPosition / (_cellWidth + _spX) * _constraintCont));
	}

	public void FreshSelectItem(int index)
	{
		var trans = transform.Find(index.ToString());
		if (trans) UpdateChildrenCallback(index, _nowIndex.IndexOf(index));
	}

	public Transform GetTransform(int index)
	{
		return transform.Find(index.ToString());
	}

	public int GetCellIndex(int index)
	{
		return _nowIndex.IndexOf(index);
	}

	public void ChangeAmount(int amount)
	{
		if (_nowMaxAmount == 0)
		{
			SetAmount(amount);
			return;
		}

		float width;
		float height;
		_nowMaxAmount = amount;
		if (_horizontal)
		{
			width = Mathf.Floor((float) amount / _constraintCont) * (_cellWidth + _spX) + _spX;
			height = _constraintCont * (_cellHeight + _spY);
			if (amount % _constraintCont != 0) width += _cellWidth + _spX;
			if (width < scrollSize.x)
			{
				width = scrollSize.x;
				scrollRect.enabled = false;
			}
			else scrollRect.enabled = true;

			_sliderLength = width - scrollSize.x;
		}

		else
		{
			width = _constraintCont * (_cellWidth + _spX);

			height = Mathf.Floor((float) amount / _constraintCont) * (_cellHeight + _spY);
			if (amount % _constraintCont != 0) height += _cellHeight + _spY;
			if (height < scrollSize.y)
			{
				height = scrollSize.y;
				scrollRect.enabled = false;
			}
			else
			{
				scrollRect.enabled = true;
			}

			_sliderLength = height - scrollSize.y;
		}

		_rect.sizeDelta = new Vector2(width, height);
	}

	/// <summary>
	/// 自动填满空位置
	/// </summary>
	/// <param name="listCount">实际长度</param>
	/// <param name="height">最低显示栏数</param>
	public void SetAmountWithFixCount(int listCount, int height)
	{
		Init();
		_showAmount = _constraintCont * height;
		if (listCount < _showAmount)
			SetAmount(_showAmount);
		else

		{
			if (listCount % _constraintCont == 0)
				SetAmount(listCount);
			else
			{
				SetAmount((listCount / _constraintCont + 1) * _constraintCont);
			}
		}
	}
}

public enum AutoSizeType
{
	None,
	OnlyCount,
	OnlySpace,
	Both
}