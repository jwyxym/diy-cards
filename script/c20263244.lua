-- 场地魔法 异晶人的古战场-死域海 (ID: 20263244)
local s,id,o=GetID()
local SET_SEVENTH=0x175 -- 「七皇」官方字段代码
local SET_NUMBER=0x48   -- 「No.」官方字段代码

function s.initial_effect(c)
	-- 场地魔法卡片表侧激活
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)

	-- ①：只要这张卡在场地区域存在，每次额外特召怪兽，那些怪兽的控制者受到500伤害
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)

	-- ②：场上有4·8星怪兽特召的场合：卡组「七皇」魔陷置顶，场上有No.101~No.107可抽1张卡 (HOPT: id)
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.topcon)
	e3:SetTarget(s.toptg)
	e3:SetOperation(s.topop)
	c:RegisterEffect(e3)

	-- ③：从手卡·场上送去墓地的场合：获得对方场上最多2只超量怪兽的控制权 (HOPT: id+o*100)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_CONTROL)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,id+o*100)
	e4:SetCondition(s.ctcon)
	e4:SetTarget(s.cttg)
	e4:SetOperation(s.ctop)
	c:RegisterEffect(e4)
end

-- ==================== ① 效果：额外特召扣血 500 ====================
function s.damfilter(c)
	return c:IsPreviousLocation(LOCATION_EXTRA)
end

function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.damfilter,nil)
	if #g==0 then return end
	local p1=g:FilterCount(Card.IsControler,nil,tp)
	local p2=g:FilterCount(Card.IsControler,nil,1-tp)
	if p1>0 and p2>0 then
		Duel.Damage(tp,p1*500,REASON_EFFECT,true)
		Duel.Damage(1-tp,p2*500,REASON_EFFECT,true)
	elseif p1>0 then
		Duel.Damage(tp,p1*500,REASON_EFFECT)
	elseif p2>0 then
		Duel.Damage(1-tp,p2*500,REASON_EFFECT)
	end
end

-- ==================== ② 效果：4·8星特召置顶「七皇」魔陷 + 可选抽卡 ====================
function s.cfilter(c)
	return c:IsFaceup() and (c:IsLevel(4) or c:IsLevel(8))
end

function s.topcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end

function s.topfilter(c)
	return c:IsSetCard(SET_SEVENTH) and (c:IsType(TYPE_SPELL) or c:IsType(TYPE_TRAP))
end

function s.no10xfilter(c)
	local no=aux.GetXyzNumber(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(SET_NUMBER)
		and no and no>=101 and no<=107
end

function s.toptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.topfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_DECK)
end

function s.topop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.topfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 卡组置顶：先洗牌，再平移到最顶端并展示确认
		Duel.ShuffleDeck(tp)
		Duel.MoveSequence(tc,SEQ_DECKTOP)
		Duel.ConfirmDecktop(tp,1)

		-- 那之后：场上有 No.101~No.107 的场合，可以抽 1 张卡
		if Duel.IsExistingMatchingCard(s.no10xfilter,tp,LOCATION_MZONE,0,1,nil)
			and Duel.IsPlayerCanDraw(tp,1)
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end

-- ==================== ③ 效果：手卡·场上送墓夺取最多2只超量怪兽控制权 ====================
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD)
end

function s.ctfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsControlerCanBeChanged()
end

function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL)
	if chk==0 then
		return ft>0 and Duel.IsExistingMatchingCard(s.ctfilter,tp,0,LOCATION_MZONE,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
end

function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL)
	local g=Duel.GetMatchingGroup(s.ctfilter,tp,0,LOCATION_MZONE,nil)
	if ft<=0 or #g==0 then return end

	local max_ct=math.min(ft,#g,2)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local sg=g:Select(tp,1,max_ct,nil)
	if #sg>0 then
		Duel.HintSelection(sg)
		Duel.GetControl(sg,tp)
	end
end