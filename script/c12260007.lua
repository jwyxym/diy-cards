--山水-覆雪
local s,id=GetID()

function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcMix(c,true,true,aux.FilterBoolFunction(Card.IsFusionSetCard,0x63a0),aux.FilterBoolFunction(Card.IsFusionType,TYPE_MONSTER),aux.FilterBoolFunction(Card.IsFusionType,TYPE_MONSTER))
	-- 去掉 aux.fuslimit 限制，允许普通特召（e0 删除）

	-- 特殊召唤方法：把自己场上包含里侧表示的3张卡送去墓地（1回合1次，同卡名共享）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.hspcon)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)

	--① 特殊召唤成功时，改变表示形式
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)

	--② 被送去墓地时，从墓地/除外选山水魔陷盖放
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+100)
	e3:SetCondition(s.setcon)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end

function s.gcheck(g)
	return g:IsExists(Card.IsFacedown,1,nil)
end

function s.used_this_turn(tp)
	return Duel.GetFlagEffect(tp,id+200)>0
end

function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	if s.used_this_turn(tp) then return false end
	local g=Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,nil)
	return #g>=3 and Duel.GetLocationCountFromEx(tp,tp,g,c)>0
end

function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetMatchingGroup(Card.IsAbleToGraveAsCost,tp,LOCATION_ONFIELD,0,nil)
	local sg=g:SelectSubGroup(tp,s.gcheck,true,3,3)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end

function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if g then
		Duel.SendtoGrave(g,REASON_COST)
		g:DeleteGroup()
	end
	Duel.RegisterFlagEffect(tp,id+200,RESET_PHASE+PHASE_END,0,1)
	local e_reg=Effect.CreateEffect(c)
	e_reg:SetType(EFFECT_TYPE_SINGLE)
	e_reg:SetCode(EFFECT_FUSION_SUMMONED)
	e_reg:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
	c:RegisterEffect(e_reg)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) or c:IsSummonType(SUMMON_TYPE_SPECIAL)
end

function s.filter(c)
	return c:IsFaceup() or c:IsFacedown()
end

function s.countfilter(c)
	return c:IsSetCard(0x63a0) and c:IsFaceup()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local count=Duel.GetMatchingGroupCount(s.countfilter,tp,LOCATION_ONFIELD,0,nil)
		return count>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	end
	local count=Duel.GetMatchingGroupCount(s.countfilter,tp,LOCATION_ONFIELD,0,nil)
	e:SetLabel(count)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,count,0,0)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local count=e:GetLabel()
	if count<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,count,nil)
	if g:GetCount()==0 then return end
	for tc in aux.Next(g) do
		if tc:IsFacedown() then
			local sel=0
			if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				sel=Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5))
			else
				sel=0
			end
			if sel==0 then
				Duel.ChangePosition(tc,POS_FACEUP_ATTACK)
			else
				Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
			end
		else
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
		end
	end
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end

function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEDOWN) and c:IsPreviousLocation(LOCATION_ONFIELD)
end

function s.setfilter(c)
	return c:IsSetCard(0x63a0) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end

function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end

function s.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SSet(tp,g:GetFirst())
	end
end
