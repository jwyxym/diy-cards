--伊瑟拉 翡翠守护巨龙
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,44990100)

	-- 特殊召唤手续
	c:EnableReviveLimit()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	-- ① 卡名当作「伊瑟拉」
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CHANGE_CODE)
	e2:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e2:SetValue(44990100)
	c:RegisterEffect(e2)

	-- ② 堆墓 + 全回合风属性自肃
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+200)
	e3:SetCondition(s.tgcon)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)

	Duel.AddCustomActivityCounter(id+200,ACTIVITY_SPSUMMON,s.counterfilter)

	-- ③ 作为超量素材赋予「伊瑟拉」战破耐性
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_BE_MATERIAL)
	e4:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e4:SetCountLimit(1,id+300)
	e4:SetCondition(s.effcon)
	e4:SetOperation(s.effop)
	c:RegisterEffect(e4)
end

-- 自肃计数器过滤
function s.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND)
end

-- 素材条件（区分卡组和其他区域）
function s.tgfilter(c)
	if c:IsLocation(LOCATION_DECK) then
		return aux.IsCodeListed(c,44990100) and not c:IsCode(id) and c:IsAbleToGrave()
	else
		return c:IsFaceupEx() and aux.IsCodeListed(c,44990100) and not c:IsCode(id)
			and (c:IsAbleToDeckAsCost() or c:IsAbleToExtraAsCost())
	end
end

-- 素材子组检查：2张且不能全是额外怪兽
function s.scheck(sg)
	if #sg~=2 then return false end
	local tc1=sg:GetFirst()
	local tc2=sg:GetNext()
	return not (tc1:IsType(TYPE_EXTRA) and tc2:IsType(TYPE_EXTRA))
end

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	return g:CheckSubGroup(s.scheck,2,2)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg=g:SelectSubGroup(tp,s.scheck,true,2,2)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else
		return false
	end
end

function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g or #g~=2 then return end
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	if tc1:IsLocation(LOCATION_HAND) then Duel.ConfirmCards(1-tp,Group.FromCards(tc1)) end
	if tc2:IsLocation(LOCATION_HAND) then Duel.ConfirmCards(1-tp,Group.FromCards(tc2)) end
	if tc1:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) then Duel.HintSelection(Group.FromCards(tc1)) end
	if tc2:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) then Duel.HintSelection(Group.FromCards(tc2)) end
	if tc1:IsType(TYPE_EXTRA) then
		Duel.SendtoExtraP(tc1,REASON_SPSUMMON)
	else
		Duel.SendtoDeck(tc1,nil,SEQ_DECKSHUFFLE,REASON_SPSUMMON)
	end
	if tc2:IsType(TYPE_EXTRA) then
		Duel.SendtoExtraP(tc2,REASON_SPSUMMON)
	else
		Duel.SendtoDeck(tc2,nil,SEQ_DECKSHUFFLE,REASON_SPSUMMON)
	end
	g:DeleteGroup()
end

-- ② 条件：互斥检查
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetCustomActivityCount(id+200,tp,ACTIVITY_SPSUMMON)>0 then return false end
	return true
end

-- ② 目标：注册全回合自肃 + 检查卡组
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return not c:IsAttribute(ATTRIBUTE_WIND) end)
	Duel.RegisterEffect(e1,tp)
end

-- ② 操作：堆墓
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

-- ③ 素材赋予战破耐性
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	if not rc then return false end
	local mg=rc:GetMaterial()
	return r==REASON_XYZ and c:IsPreviousLocation(LOCATION_ONFIELD)
		and mg:FilterCount(Card.IsXyzType,nil,TYPE_MONSTER)==mg:GetCount()
		and rc:IsSetCard(0xcf1)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end