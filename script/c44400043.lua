-- 行星之寂镭
local s,id,o=GetID()
local SET_YE_CU=0x97f          -- 「业簇」字段
local SET_CRYSTAL_FLOWER=0x68f -- 「水晶花」字段
local CARD_DINATO_TUNA=44400046 -- 「狄娜托·图娜」

function s.initial_effect(c)
	aux.AddCodeList(c,CARD_DINATO_TUNA)

	-- 卡的发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)

	-- ①：自己主要阶段才能发动。选卡组１张「业簇」卡或者「水晶花」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	-- ②-1：对方不能把自己场上有装备卡装备的怪兽解放
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD)
	e2a:SetCode(EFFECT_CANNOT_RELEASE)
	e2a:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2a:SetRange(LOCATION_FZONE)
	e2a:SetTargetRange(0,1)
	e2a:SetCondition(s.con2)
	e2a:SetTarget(s.reltg)
	c:RegisterEffect(e2a)
	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_FIELD)
	e2b:SetCode(EFFECT_UNRELEASABLE_SUM)
	e2b:SetRange(LOCATION_FZONE)
	e2b:SetTargetRange(LOCATION_MZONE,0)
	e2b:SetCondition(s.con2)
	e2b:SetTarget(s.unreltg)
	e2b:SetValue(s.unrelval)
	c:RegisterEffect(e2b)
	local e2c=e2b:Clone()
	e2c:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e2c)

	-- ②-2：那些怪兽１回合各有１次不会被战斗破坏
	local e2d=Effect.CreateEffect(c)
	e2d:SetType(EFFECT_TYPE_FIELD)
	e2d:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2d:SetRange(LOCATION_FZONE)
	e2d:SetTargetRange(LOCATION_MZONE,0)
	e2d:SetCondition(s.con2)
	e2d:SetTarget(s.indtg)
	e2d:SetValue(s.indval)
	c:RegisterEffect(e2d)

	-- ③：对方把效果发动的场合才能发动。自己场上的１只「狄娜托·图娜」除外。那只怪兽回到场上，从墓地尽可能地把「业簇」装备魔法卡给那只怪兽装备（同名卡最多１张）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_EQUIP+CATEGORY_GRAVE_ACTION)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,id+o*100)
	e3:SetCondition(s.con3)
	e3:SetTarget(s.tg3)
	e3:SetOperation(s.op3)
	c:RegisterEffect(e3)
end

--------------------------------------------------------------------------------
-- ①效果：主要阶段检索「业簇」或「水晶花」卡
--------------------------------------------------------------------------------
function s.thfilter(c)
	return (c:IsSetCard(SET_YE_CU) or c:IsSetCard(SET_CRYSTAL_FLOWER)) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--------------------------------------------------------------------------------
-- ②效果：3张以上装备卡时防解放与战破抗性
--------------------------------------------------------------------------------
function s.eqcountfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EQUIP)
end

function s.con2(e)
	local tp=e:GetHandlerPlayer()
	return Duel.GetMatchingGroupCount(s.eqcountfilter,tp,LOCATION_SZONE,0,nil)>=3
end

function s.reltg(e,c)
	return c:IsControler(e:GetHandlerPlayer()) and c:GetEquipCount()>0
end

function s.unreltg(e,c)
	return c:GetEquipCount()>0
end

function s.unrelval(e,re,rp)
	return rp==1-e:GetHandlerPlayer()
end

function s.indtg(e,c)
	return c:GetEquipCount()>0
end

function s.indval(e,re,r,rp)
	if r&REASON_BATTLE~=0 then
		return 1
	else
		return 0
	end
end

--------------------------------------------------------------------------------
-- ③效果：对方发效时自身「狄娜托·图娜」暂离回场并批量装备「业簇」
--------------------------------------------------------------------------------
function s.con3(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end

function s.dina_rm_filter(c)
	return c:IsFaceup() and c:IsCode(CARD_DINATO_TUNA) and c:IsAbleToRemove()
end

function s.tg3(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.dina_rm_filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE)
end

function s.eqfilter3(c,tc,tp)
	return c:IsSetCard(SET_YE_CU) and c:IsType(TYPE_EQUIP) and c:CheckUniqueOnField(tp) and c:CheckEquipTarget(tc)
end

function s.op3(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.dina_rm_filter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if not tc then return end

	-- 自己场上的１只「狄娜托·图娜」除外
	if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)>0 and tc:IsLocation(LOCATION_REMOVED) then
		-- 那只怪兽回到场上
		if Duel.ReturnToField(tc) and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
			local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
			local eqg=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.eqfilter3),tp,LOCATION_GRAVE,0,nil,tc,tp)
			if ft>0 and #eqg>0 then
				Duel.BreakEffect()
				local max_equip=math.min(ft,eqg:GetClassCount(Card.GetCode))
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
				local sg=eqg:SelectSubGroup(tp,aux.dncheck,false,1,max_equip)
				if sg and #sg>0 then
					for ec in aux.Next(sg) do
						Duel.Equip(tp,ec,tc,true,true)
					end
					Duel.EquipComplete()
				end
			end
		end
	end
end