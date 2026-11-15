-- 业簇之刃-R44链锯剑
local s,id,o=GetID()
local SET_YE_CU=0x97f          -- 「业簇」字段
local SET_CRYSTAL_FLOWER=0x68f -- 「水晶花」字段
local CARD_DINATO_TUNA=44400046 -- 「狄娜托·图娜」

function s.initial_effect(c)
	aux.AddCodeList(c,CARD_DINATO_TUNA)

	-- 装备魔法卡规则限制
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EFFECT_EQUIP_LIMIT)
	e0:SetValue(1)
	c:RegisterEffect(e0)

	-- ①：选手卡１张「狄娜托·图娜」给对方确认才能发动。那只怪兽特殊召唤并把这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.target1)
	e1:SetOperation(s.operation1)
	c:RegisterEffect(e1)

	-- ②-1：攻击力上升装备的卡的数量×１０００
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_EQUIP)
	e2a:SetCode(EFFECT_UPDATE_ATTACK)
	e2a:SetCondition(s.gaincon)
	e2a:SetValue(s.atkval)
	c:RegisterEffect(e2a)

	-- ②-2：不会被战斗破坏
	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_EQUIP)
	e2b:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2b:SetCondition(s.gaincon)
	e2b:SetValue(1)
	c:RegisterEffect(e2b)

	-- ②-3：可以对对方场上全部特殊召唤的怪兽各作１次攻击宣言
	local e2c=Effect.CreateEffect(c)
	e2c:SetType(EFFECT_TYPE_EQUIP)
	e2c:SetCode(EFFECT_ATTACK_ALL)
	e2c:SetCondition(s.gaincon)
	e2c:SetValue(s.atkfilter)
	c:RegisterEffect(e2c)

	-- ②-4：战斗破坏的怪兽不去墓地而除外
	local e2d=Effect.CreateEffect(c)
	e2d:SetType(EFFECT_TYPE_EQUIP)
	e2d:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e2d:SetCondition(s.gaincon)
	e2d:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e2d)

	-- ②-5：有卡被除外的场合给予对方５００点伤害
	local e2e=Effect.CreateEffect(c)
	e2e:SetDescription(aux.Stringid(id,1))
	e2e:SetCategory(CATEGORY_DAMAGE)
	e2e:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2e:SetCode(EVENT_REMOVE)
	e2e:SetRange(LOCATION_MZONE)
	e2e:SetTarget(s.damtg)
	e2e:SetOperation(s.damop)
	local e2grant=Effect.CreateEffect(c)
	e2grant:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e2grant:SetRange(LOCATION_SZONE)
	e2grant:SetTargetRange(LOCATION_MZONE,0)
	e2grant:SetTarget(s.eftg)
	e2grant:SetLabelObject(e2e)
	c:RegisterEffect(e2grant)

	-- ③：这张卡从卡组以外被送去墓地的场合才能发动。选卡组１张「水晶花」·「业簇」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o*100)
	e3:SetCondition(s.thcon3)
	e3:SetTarget(s.thtg3)
	e3:SetOperation(s.thop3)
	c:RegisterEffect(e3)
end

--------------------------------------------------------------------------------
-- ①效果：展示手卡「狄娜托·图娜」特召并装备
--------------------------------------------------------------------------------
function s.cfilter(c,e,tp)
	return c:IsCode(CARD_DINATO_TUNA) and not c:IsPublic() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end

function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
	g:GetFirst():CreateEffectRelation(e)
	e:SetLabelObject(g:GetFirst())
end

function s.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end

function s.operation1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if not tc or not tc:IsRelateToEffect(e) or not tc:IsLocation(LOCATION_HAND) then return end
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		if c:IsRelateToEffect(e) and not c:IsStatus(STATUS_LEAVE_CONFIRMED) then
			Duel.Equip(tp,c,tc)
		end
	end
end

--------------------------------------------------------------------------------
-- ②效果：装备「狄娜托·图娜」时的获得效果
--------------------------------------------------------------------------------
function s.gaincon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:IsCode(CARD_DINATO_TUNA)
end

function s.atkval(e,c)
	return c:GetEquipCount()*1000
end

function s.atkfilter(e,c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end

function s.eftg(e,c)
	return c==e:GetHandler():GetEquipTarget() and c:IsCode(CARD_DINATO_TUNA)
end

function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(500)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end

function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end

--------------------------------------------------------------------------------
-- ③效果：从卡组以外送墓检索「水晶花」·「业簇」卡
--------------------------------------------------------------------------------
function s.thcon3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not c:IsPreviousLocation(LOCATION_DECK)
end

function s.thfilter3(c)
	return (c:IsSetCard(SET_CRYSTAL_FLOWER) or c:IsSetCard(SET_YE_CU)) and c:IsAbleToHand()
end

function s.thtg3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter3,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop3(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter3,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end