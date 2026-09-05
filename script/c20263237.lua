-- 雷之忍者-冥劫
local s,id,o=GetID()
local SET_NINJA=0x2b    -- 「忍者」字段代码
local SET_NINJITSU=0x61 -- 「忍法」字段代码

function s.initial_effect(c)
	-- ①：以自己场上的 1 只里侧守备表示怪兽为对象才能发动。这张卡从手卡特殊召唤，那张卡变为表侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- ②：这张卡特殊召唤·反转的场合可以发动。从卡组把 1 张「忍者」卡或者「忍法」卡除外，这个效果除外的卡在这个回合结束阶段在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o*100)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_FLIP)
	c:RegisterEffect(e3)
end

-- ①效果：里侧守备怪兽过滤
function s.posfilter(c)
	return c:IsFacedown() and c:IsDefensePos()
end

-- ①效果：Target
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.posfilter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and Duel.IsExistingTarget(s.posfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(tp,s.posfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end

-- ①效果：Operation
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		if tc and tc:IsRelateToEffect(e) and tc:IsFacedown() then
			Duel.BreakEffect()
			Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
		end
	end
end

-- ②效果：从卡组除外的「忍者」或「忍法」卡过滤
function s.rmfilter(c)
	return (c:IsSetCard(SET_NINJA) or c:IsSetCard(SET_NINJITSU)) and c:IsAbleToRemove()
end

-- ②效果：Target
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end

-- ②效果：Operation
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_REMOVED) then
		-- 注册结束阶段在场上盖放的处理
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabelObject(tc)
		e1:SetCondition(s.setcon)
		e1:SetOperation(s.setop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

-- ②效果：延时盖放 Condition
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc or not tc:IsLocation(LOCATION_REMOVED) then return false end
	if tc:IsType(TYPE_MONSTER) then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
	else
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and tc:IsSSetable()
	end
end

-- ②效果：延时盖放 Operation
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc or not tc:IsLocation(LOCATION_REMOVED) then return end
	if tc:IsType(TYPE_MONSTER) then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) then
			Duel.Hint(HINT_CARD,0,id)
			if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)>0 then
				Duel.ConfirmCards(1-tp,tc)
			end
		end
	else
		if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and tc:IsSSetable() then
			Duel.Hint(HINT_CARD,0,id)
			Duel.SSet(tp,tc)
		end
	end
end