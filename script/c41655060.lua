-- 烬雪的霜君·格罗姆海尔
local s,id,o=GetID()
function s.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c,false)
	--synchro summon
	c:EnableReviveLimit()
	aux.AddSynchroMixProcedure(c,s.matfilter,nil,nil,aux.NonTuner(nil),1,1)
	--P效①：对方发动魔陷效果时
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	s.jinxue_effect=e1
	--怪兽①：可以对对方场上所有怪兽各作1次攻击
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_ATTACK_ALL)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--怪兽②：伤害计算时，攻击力上升额外卡组表侧烬雪怪兽数量×250
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(68507541,0))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetCondition(s.atkcon1)
	e3:SetOperation(s.atkop1)
	c:RegisterEffect(e3)
	--怪兽③：怪兽区域被破坏时在P区放置
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,id+2)
	e4:SetCondition(s.pencon)
	e4:SetTarget(s.pentg)
	e4:SetOperation(s.penop)
	c:RegisterEffect(e4)
end

function s.matfilter(c,syncard)
	return c:IsTuner(syncard) or c:IsType(TYPE_NORMAL)
end

-- P效① 条件
function s.jxdesfilter(c)
	return c:IsSetCard(0xe93) and c:IsDestructable()
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return false end
	if not re:IsActiveType(TYPE_SPELL+TYPE_TRAP) then return false end
	-- 自己场上必须有2张以上烬雪卡
	return Duel.IsExistingMatchingCard(s.jxdesfilter,tp,LOCATION_ONFIELD,0,2,nil)
end
function s.costfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsDiscardable()
end
function s.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 对方可以丢弃1张陷阱卡使这个效果无效
	if Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil)
		and Duel.IsChainDisablable(0) and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then
		Duel.DiscardHand(1-tp,s.costfilter,1,1,REASON_EFFECT+REASON_DISCARD)
		Duel.NegateEffect(0)
		return
	end
	-- 对方场上的魔陷全部无效并破坏
	local dg=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_ONFIELD,nil)
	if #dg>0 then
		for tc in aux.Next(dg) do
			if tc:IsCanBeDisabledByEffect(e) then
				Duel.NegateRelatedChain(tc,RESET_TURN_SET)
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e2)
			end
		end
		Duel.AdjustInstantly()
		Duel.Destroy(dg,REASON_EFFECT)
	end
	-- 自己场上2张「烬雪」卡破坏
	local jg=Duel.GetMatchingGroup(s.jxdesfilter,tp,LOCATION_ONFIELD,0,nil)
	if #jg>=2 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=jg:Select(tp,2,2,nil)
		Duel.Destroy(sg,REASON_EFFECT)
	end
end

-- 怪兽② 加攻
function s.atkcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler()==Duel.GetAttacker()
end
function s.atkop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(s.atkval)
		c:RegisterEffect(e1)
	end
end
function s.vfilter(c)
	return c:IsSetCard(0xe93) and c:IsFaceup()
end
function s.atkval(e,c)
	return Duel.GetMatchingGroupCount(s.vfilter,c:GetControler(),LOCATION_EXTRA,0,nil)*250
end

-- 怪兽③：被破坏时在P区放置
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsLocation(LOCATION_GRAVE)
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1)
	end
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or not c:IsLocation(LOCATION_GRAVE) then return end
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
end