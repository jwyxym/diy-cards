local s,id,o=GetID()
function s.initial_effect(c)
    c:EnableReviveLimit()
    aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsSetCard,0x2b1),3,false)
    -- ① 最多3次攻击（1普攻+2额外）
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_EXTRA_ATTACK)
    e1:SetCondition(s.acon)
    e1:SetValue(2)
    c:RegisterEffect(e1)
    -- ② 1星战对方→ATK/DEF=0+1000伤
    local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
    -- ② 伤害步骤结束→1000伤害
    local e2c=Effect.CreateEffect(c)
    e2c:SetDescription(aux.Stringid(id,1))
    e2c:SetCategory(CATEGORY_DAMAGE)
    e2c:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2c:SetCode(EVENT_DAMAGE_STEP_END)
    e2c:SetRange(LOCATION_MZONE)
    e2c:SetCondition(s.damcon)
    e2c:SetOperation(s.damop)
    c:RegisterEffect(e2c)
    -- ③ 魔陷发动→炸1（1回合2次）
    local e3=Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id,0))
    e3:SetCategory(CATEGORY_DESTROY)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_CHAINING)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetRange(LOCATION_MZONE)
    e3:SetCountLimit(2,id)
    e3:SetCondition(s.descon)
    e3:SetTarget(s.destg)
    e3:SetOperation(s.desop)
    c:RegisterEffect(e3)
end
function s.acon(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    return c:IsSummonType(SUMMON_TYPE_FUSION)
end
-- ②
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if a and d and ((a:IsLevel(1) and a:IsControler(tp) and d:IsControler(1-tp)) or (d:IsLevel(1) and d:IsControler(tp) and a:IsControler(1-tp))) then
	    if a:IsControler(1-tp) then d=a end
		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_SET_BATTLE_ATTACK)
		e4:SetReset(RESET_PHASE+PHASE_DAMAGE)
		e4:SetValue(0)
		d:RegisterEffect(e4,true)
		local e5=Effect.CreateEffect(e:GetHandler())
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetCode(EFFECT_SET_BATTLE_DEFENSE)
		e5:SetReset(RESET_PHASE+PHASE_DAMAGE)
		e5:SetValue(0)
		d:RegisterEffect(e5,true)
	end
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
    local a=Duel.GetAttacker()
    local d=Duel.GetAttackTarget()
    return a and d and ((a:IsLevel(1) and a:IsControler(tp) and d:IsControler(1-tp)) or (d:IsLevel(1) and d:IsControler(tp) and a:IsControler(1-tp)))
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Damage(1-tp,1000,REASON_EFFECT)
end
-- ③
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsOnField() end
    if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
    Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then Duel.Destroy(tc,REASON_EFFECT) end
end
