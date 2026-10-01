--哀叹之龙-莱茵
local s,id,o=GetID()
function s.initial_effect(c)
	--同调召唤
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	--等级上升    
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
    e1:SetCondition(s.lvcon)
    e1:SetTarget(s.lvtg)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)    
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
	--选择效果发动    
    local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetCondition(s.efcon)
	e3:SetTarget(s.eftg)
	e3:SetOperation(s.efop)
	c:RegisterEffect(e3)
	--攻击力上升    
    local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(s.atkcon)
	e4:SetValue(1500)
	c:RegisterEffect(e4)
	--战破抗性    
    local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e5:SetCondition(s.indcon)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	--不能作为效果对象    
    local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e6:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e6:SetRange(LOCATION_MZONE)
    e6:SetCondition(s.tgcon)
	e6:SetValue(aux.tgoval)
	c:RegisterEffect(e6)
	--贯穿伤害    
    local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_PIERCE)
    e7:SetCondition(s.pecon)
	c:RegisterEffect(e7)
	--多次攻击    
    local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_SINGLE)
	e8:SetCode(EFFECT_ATTACK_ALL)
	e8:SetCondition(s.bdcon)
	e8:SetValue(1)
	c:RegisterEffect(e8)
end
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end    
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
function s.efcon(e)
	local c=e:GetHandler()
	return c:IsLevelAbove(12) and Duel.GetAttacker()==c
end
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local b1=Duel.IsExistingMatchingCard(nil,tp,0,LOCATION_ONFIELD,1,nil)
    local b2=Duel.IsPlayerCanDraw(tp,1)
    if chk==0 then return (b1 or b2) end
    local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,2),1},
		{b2,aux.Stringid(id,3),2})        
	e:SetLabel(op)
    if op==1 then
    	e:SetCategory(CATEGORY_DESTROY)
        e:SetProperty(0)
        local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_ONFIELD,nil)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
    elseif op==2 then
    	e:SetCategory(CATEGORY_DRAW)
        e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    	Duel.SetTargetPlayer(tp)
		Duel.SetTargetParam(1)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
    end    
    Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
    local c=e:GetHandler()
	if op==1 then
    	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,nil,tp,0,LOCATION_ONFIELD,1,1,nil)
		if g:GetCount()>0 then
			Duel.HintSelection(g)
			Duel.Destroy(g,REASON_EFFECT)
		end
    elseif op==2 then
    	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Draw(p,d,REASON_EFFECT)
    end
end    
function s.atkcon(e)
	return e:GetHandler():IsLevelAbove(12)
end
function s.indcon(e)
	return e:GetHandler():IsLevelAbove(8)
end
function s.tgcon(e)
	return e:GetHandler():IsLevelAbove(9)
end
function s.pecon(e)
	return e:GetHandler():IsLevelAbove(10)
end
function s.bdcon(e)
	return e:GetHandler():IsLevelAbove(11)
end