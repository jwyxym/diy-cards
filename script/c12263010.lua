-- c12263010.lua
-- 天水·永续陷阱
local s,id,o=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	--① 1回合1次，自己·对方回合，取对象破坏
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START+TIMING_BATTLE_END+TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)

	--② 墓地存在，卡被破坏送去墓地的场合发动
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,122630102)
	e2:SetCondition(s.gycon)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
end

-- 天水字段
local SET_TENSUI=0x5244

-- ==================== ① ====================
function s.desfilter1(c)
	return c:IsDestructable()
end

function s.desfilter2(c)
	return c:IsDestructable() and (c:IsType(TYPE_LINK) or c:IsType(TYPE_RITUAL) or c:IsSetCard(SET_TENSUI))
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.desfilter1,tp,0,LOCATION_ONFIELD,1,nil)
			and Duel.IsExistingMatchingCard(s.desfilter2,tp,LOCATION_ONFIELD,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g1=Duel.SelectMatchingCard(tp,s.desfilter1,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g2=Duel.SelectMatchingCard(tp,s.desfilter2,tp,LOCATION_ONFIELD,0,1,1,nil)
	if #g1>0 and #g2>0 then
		g1:Merge(g2)
		Duel.SetTargetCard(g1)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,2,0,0)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1500)
	end
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local ct=0
	if #g>0 then
		ct=Duel.Destroy(g,REASON_EFFECT)
	end
	if ct<2 then
		Duel.Damage(1-tp,1500,REASON_EFFECT)
	end
end

-- ==================== ② ====================
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_GRAVE) then return false end
	return eg:IsExists(function(tc)
		return tc:IsReason(REASON_DESTROY) and tc:IsLocation(LOCATION_GRAVE)
	end,1,nil)
end

function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end

function s.count_linkrit()
	local g=Duel.GetMatchingGroup(function(c)
		return c:IsType(TYPE_LINK) or c:IsType(TYPE_RITUAL)
	end,0,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,nil)
	return #g
end

function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end

	if Duel.MoveToField(c,tp,tp,LOCATION_SZONE,POS_FACEUP,true)==0 then return end

	local opt=Duel.SelectOption(tp,aux.Stringid(id,2),aux.Stringid(id,3))
	if opt==0 then
		local ct=s.count_linkrit()
		if ct>0 then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetTargetRange(LOCATION_MZONE,0)
			e1:SetValue(ct*500)
			e1:SetReset(RESET_PHASE+PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	else
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_PIERCE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end

